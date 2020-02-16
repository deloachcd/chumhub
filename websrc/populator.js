remote_metafile = "https://deloachcd.github.io/websrc/meta.json"

fetch(remote_metafile)
    .then((response) => {
        return response.json();
    })
    .then((json_metadata) => {
        console.log(json_metadata)
    });
