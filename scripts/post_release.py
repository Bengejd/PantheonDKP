from discord import Webhook, RequestsWebhookAdapter, Embed
import requests
import time
import sys

if len(sys.argv) != 2:
    print("Invalid arguments")
    exit(1)

GIT_ENDPOINT = "https://api.github.com/repos/Bengejd/PantheonDKP/releases"
CHANGELOG_ENDPOINT = "https://raw.githubusercontent.com/Bengejd/PantheonDKP/release/Markdown/CHANGELOG.md"

def get_newest_release():
    num_calls = 0
    while True:
        num_calls = num_calls + 1
        response = requests.get(GIT_ENDPOINT)
        if response.status_code == 200:
            return response.json()
        else:
            print("Query failed")
            if num_calls >= 10:
                print("Exiting")
                exit(10)
            else:
                print("Sleeping and retrying")
                time.sleep(num_calls)

def get_newest_changelog():
    num_calls = 0
    while True:
        num_calls = num_calls + 1
        response = requests.get(CHANGELOG_ENDPOINT)
        if response.status_code == 200:
            return response.content
        else:
            print("Changelog Query failed")
            if num_calls >= 10:
                print("exiting")
                exit(10)
            else:
                print("Sleeping and retrying")
                time.sleep(num_calls)

releases = get_newest_release()
changelog = get_newest_changelog()

if len(releases) == 0:
    print("No releases found")
    exit(20)

def get_pretty_changelog(currTag, prevTag):
        if len(changelog) == 0:
            return "No changelog attached"
        else:
            s = changelog
            prev_tag = f'## {prevTag}'.encode()
            curr_tag = f'## {currTag}'.encode()
            return s[s.find(curr_tag)+len(curr_tag):s.rfind(prev_tag)].decode().replace('### ', '\n').replace('\n\n', '\n').strip()

def split_longer_embed(changelog):
    line = changelog
    n = 1000
    return [line[i:i+n] for i in range(0, len(line), n)]

try:
    author = releases[0]["author"]["login"]
    body = releases[0]["body"]
    multibody = None
    if len(body) > 1000:
        multibody = body.split("\r\n\r\n")

    tag = releases[0]["tag_name"]
    prev_tag = releases[1]["tag_name"]
    name = releases[0]["name"]
    prerelease = releases[0]["prerelease"]

    pretty_changelog = get_pretty_changelog(tag, prev_tag)

    embed = {
        "author": {"name": "PantheonDKP has been updated!"},
        "title": name,
        "color": 14464841,
        "fields": [],
        "footer": {"text": "Released by " + author + " (Neekio)"}
    }

    if len(pretty_changelog) > 1000:
        multibody = split_longer_embed(pretty_changelog)

    if multibody is not None:
        first = True
        for body in multibody:
            if len(body) > 0:
                title = "**CHANGELOG**" if first else "\u200b"
                embed["fields"].append({"name": title, "value": "```" + body + "```", "inline": False})
                first = False
    else:
        if len(body) > 0:
            embed["fields"].append({"name": "**CHANGELOG**", "value": "```" + body + "```", "inline": False})
        else:
            embed["fields"].append({"name": "CHANGELOG", "value": "`" + pretty_changelog + "`", "inline": False})
    if prerelease:
        embed["description"] = "_This is a beta version and may still contain bugs_"

    webhook = Webhook.from_url(sys.argv[1], adapter = RequestsWebhookAdapter())
    if prerelease:
        webhook.send(embed = Embed.from_dict(embed))
    else:
        webhook.send(content = "@everyone", embed = Embed.from_dict(embed))
except Exception as e:
    print(str(e))
    exit(30)

