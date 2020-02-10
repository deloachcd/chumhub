remote_metafile = "https://deloachcd.github.io/meta.json"

metadata = fetch(remote_metafile)
    .then((response) => {
        return response.json();
    });

console.log(metadata);