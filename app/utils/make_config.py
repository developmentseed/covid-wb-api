import yaml

# Load main config
with open("app/templates/config.yml", "r") as stream:
    pygeoapi = yaml.safe_load(stream)

with open("app/templates/pg_resource.yml", "r") as stream:
    pgr = yaml.safe_load(stream)

pygeoapi["resources"] = {}


def add_pg_resource(table, description):
    global pygeoapi
    global pgr
    r = pgr.copy()
    r["title"] = table
    r["description"] = description
    r["provider"]["table"] = table
    pygeoapi["resources"][table] = r
    return pygeoapi


add_pg_resource("adm0", "Admin 0 Boundaries")
add_pg_resource("adm1", "Admin 1 Boundaries")
add_pg_resource("adm2", "Admin 2 Boundaries")

with open("constructed.config.yml", "w") as outfile:
    yaml.dump(pygeoapi, outfile)
