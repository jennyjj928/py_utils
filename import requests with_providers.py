import requests
import csv
import time
import pickle
import json

auth = "Bearer 9536ce02ead1891925f66de21b27bea7"
jwt = ""


def init_jwt():
    resp = requests.get("https://cloud.bytedance.net/auth/api/v1/jwt",
                        headers={"Authorization": auth})
    global jwt
    jwt = resp.headers["X-Jwt-Token"]
    print(jwt)


init_jwt()


def cache_for(ttl=600):
    def wrap(fn):
        def _(*args, **kw):
            key = pickle.dumps((args, kw))
            if (key not in fn.__dict__ or
                    fn.__dict__[key][-1] < time.time()):
                v = fn(*args, **kw)
                fn.__dict__[key] = (v, time.time() + ttl)
                return v
            return fn.__dict__[key][0]

        return _

    return wrap


def iter_nodes(ori_url, offset=0, limit=500):
    """
    iter bytetree nodes
    """
    while 1:
        url = f"{ori_url}&offset={offset}&page_size={limit}"
        print("Fetching data: ", url)
        resp = None
        try:
            resp = requests.get(url, headers={"x-jwt-token": jwt})
            if resp.status_code != 200:
                print(resp.status_code)
                return
        except Exception as e:
            print(e)
            return

        data = resp.json()
        for item in data["data"]:
            yield item

        if data["pagination"]["has_next"]:
            offset = data["pagination"]["next"]
        else:
            break


def validate_rds_psm(psm):
    """
    filter rds psm by suffix read,
    for write psm, strip "write" suffix to normalize name
    """
    if "toutiao.mysql" in psm and "write" in psm:
        return psm[:-6]
    print("ignored psm:", psm)
    return ""

def get_psm(psm):
    return psm

def get_path(node):
    path = node["path"]
    i18n_path = node["i18n_path"]
    
    return path, i18n_path


def get_vdcs(node):
    """
    find vdcs of a node
    """
    vdcs = []
    for item in node["resources"]:
        # if item["region"] == "cn":
        #     continue
        vdc = item["vregion"] + "/" + item["vdc"] + "|" + item["region"]
        vdcs.append(vdc)
    return ",".join(set(vdcs))

def get_env(node):
    # demo: 'env': 'boe/prod'

    for item in node["resources"]:
        env_str = item["env"]

        if env_str == "":
            print("envstr is nil")
            continue

        envs = env_str.split("/")
        if not envs:
            print("envs is empty")
        

        for env in envs:
            print("env:", env)
            if env == "prod":
                return env_str
    
    print("envs has no prod")
    return ""    

def get_owners(node):
    """
    find owners of a node by updated_by
    """
    owners = [node["created_by"]] if "created_by" in node else []
    for item in node["resources"]:
        if item["updated_by"] not in ("db_platform", "service_tree"):
            owners.append(item["updated_by"])
    return ",".join(set(owners))


def get_vdcs(node):
    """
    find vdcs of a node
    """
    vdcs = []
    for item in node["resources"]:
        # if item["region"] == "cn":
        #     continue
        vdc = item["vregion"] + "/" + item["vdc"] + "|" + item["region"]
        vdcs.append(vdc)
    return ",".join(set(vdcs))

def main():
    providers = ["tce","bytefaas","cronjob"]

    for provider_tmp in providers:
        provider = provider_tmp
        parent_ids = ["646332"]
        rows = []
        for parent_id in parent_ids:
            url = f"https://bytetree.byted.org/service_meta/api/v4/index/nodes/{parent_id}/children?is_leaf=true&resource.provider={provider}"
            for node in iter_nodes(url):
                psm = get_psm(node["name"])
                if not psm:
                    continue
                print("Processing: ", psm, "...")
                # print("Node:", node)
                owners = get_owners(node)
                # vdcs = get_vdcs(node)
                env_str = get_env(node)
                path,i18n_path = get_path(node)

                if env_str:
                    rows.append([psm, provider, env_str, path, i18n_path, owners, node.get("description", "")])

        print("Total: ", len(rows))
        with open("psms_providers.csv", encoding="utf-8",mode="a") as f:
            w = csv.writer(f)
            w.writerows(rows)


if __name__ == "__main__":
    main()
