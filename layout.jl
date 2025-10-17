Html.head([
    Html.meta(charset="UTF-8"),
    Html.meta(name="viewport", content="width=device-width, initial-scale=1.0"),
    Html.title("WiNDC National Dashboard"),
    #Html.link(rel="stylesheet", href="/assets/styles.css"),
    #Html.script(src="/assets/scripts.js")
])
cell(style="display: flex; justify-content: space-between; align-items: center; background-color: #112244; padding: 10px 50px; color: #ffffff; top: 0; width: 100%; box-sizing: border-box;", [
    cell(style="font-size: 1.5em; font-weight: bold;",
        "WiNDC National Dashboard"
    ),
])
page(model, partial=true, [@yield])