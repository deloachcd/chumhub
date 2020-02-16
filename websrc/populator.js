// global constants
let remote_metafile = "https://deloachcd.github.io/websrc/meta.json"
let albums_table = document.getElementById("albums");
let sidenav = document.getElementById("sidenav");
let sidenav_tags_list = []

function sidenav_create_tag(tagliteral) {
    /*<div class="tag">
      <input type="checkbox" name="tag_focus" value="false"></input>
      <label for="tag_focus">focus</label>
    </div>*/
    var new_element = document.createElement("div");
    new_element.setAttribute("class", "tag");
    checkbox = document.createElement("input")
    checkbox.setAttribute("type", "checkbox");
    checkbox.setAttribute("name", `checkbox_${tagliteral}`);
    checkbox.setAttribute("value", false);
    label = document.createElement("label");
    label.setAttribute("for", `checkbox_${tagliteral}`);
    label.appendChild(document.createTextNode(`${tagliteral}`))
    new_element.appendChild(checkbox);
    new_element.appendChild(label);
    sidenav.appendChild(new_element);
}

function main() {
    fetch(remote_metafile)
        .then((response) => {
            return response.json();
        })
        .then((json_metadata) => {
            var collection = json_metadata.collection;
            collection.forEach((entry, index) => {
                console.log(`${entry.album} - ${entry.artist}`)
                entry.tags.forEach((tagname, index) => {
                    if (sidenav_tags_list.indexOf(tagname) == -1) {
                        // tag not in sidenav
                        sidenav_create_tag(tagname)
                        sidenav_tags_list.push(tagname)
                    }
                })
            })
        });
}

main();