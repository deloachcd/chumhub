// global constants
let remote_metafile = "https://deloachcd.github.io/websrc/meta.json"
let albums_table = document.getElementById("albums");
let sidenav = document.getElementById("sidenav");
let sidenav_tags_list = []
let table_count = 0
let table_maxwidth = 5

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

function appendToSidenav(tags) {
    tags.forEach((tagname, index) => {
        if (sidenav_tags_list.indexOf(tagname) == -1) {
            // tag not in sidenav
            sidenav_create_tag(tagname);
            sidenav_tags_list.push(tagname);
        }
    })
}

function renderAlbum(collection_entry) {
    var album = collection_entry.album;
    var artist = collection_entry.artist;
    var image = document.createElement("img");
    image.setAttribute("src", collection_entry.cover);
    var td_element = document.createElement("td");
    td_element.setAttribute("valign", "top");
    td_element.appendChild(image);
    td_element.appendChild(document.createTextNode(
        `${artist} - ${album}`
    )); 
    // limit row width to table_maxwidth constant
    if (table_count == table_maxwidth) {
        table_count = 0
    }
    if (table_count == 0) {
        albums_table.appendChild(document.createElement("tr"));
    }
    // target is last row of table
    var table_rows = albums_table.rows;
    var targetAppendRow = table_rows[table_rows.length-1];
    targetAppendRow.appendChild(td_element);
    table_count++;
}

function initial() {
    fetch(remote_metafile)
        .then((response) => {
            return response.json();
        })
        .then((json_metadata) => {
            var collection = json_metadata.collection;
            collection.forEach((entry, index) => {
                // Populate sidenav from tags
                appendToSidenav(entry.tags);
                // Render every album (we don't care about tags yet)
                renderAlbum(entry);
            })
        });
}

initial();