---
date: 2019-07-27
layout: layouts/post.njk
permalink: "{{ page.date | date: '%Y' }}/{{ page.fileSlug }}/"
description: Setting local files as New Tab page in Firefox
keywords: firefox, newtabpage, startpage, r/startpages
title: Setting local files as New Tab page in Firefox
---

> This will not work as of Firefox 72

So, I was going through [`r/startpages`](https://www.reddit.com/r/startpages/) and checking out the `startpages` there.
A lot of them looked pretty awesome and I decided to create one. And create, I did [meain/startpage](https://github.com/meain/startpage).

But yea, setting a local file as startpage is a messy deal in Firefox.
Lot of people seem to set up a local server and even after than end up having to use a plugin to get things working.

Here is a bit complex but much better way to do it. Lets get started.

Firefox lets you change the css of the browser by providing custom css file called [userChrome.css](https://github.com/meain/dotfiles/blob/master/firefox/userChrome.css).
What we do is, load a javascript file using this css file and change Firefox setting using that js file.

> As of Firefox 69, you might have to manually set the value of `toolkit.legacyUserProfileCustomizations.stylesheets` to
> `true` in `about:config`

### Set up `userChrome.css`

The first step is to create a file called `userChrome.css` file in your `<profile>/chrome` directory.
To find out Firefox's profile directory, you can check in `Help` > `Troubleshooting Information` section in the
hamburger menu in the top right of the browser.

You will land in a page which look something like this.

![Troubleshooting Info Page](https://i.imgur.com/VpCfMAG.png)

Mine is `/Users/meain/Library/Application Support/Firefox/Profiles/jxqrburh.default-release`.

So you go to this folder. There may or may not be a folder called `chrome`. In any case create a file named
`userChrome.css` in the `chrome` folder inside your profile folder.

### Use `userChrome.css` to load js file

Now let us get the css file to load the js file, in our case `userChrome.js`.
Credis to [Sporif/firefox-quantum-userchromejs](https://github.com/Sporif/firefox-quantum-userchromejs).

Add this code to `userChrome.css` file:

```css
@namespace url(http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul);

toolbarbutton#alltabs-button {
    -moz-binding: url("userChrome.xml#js");
}
```

You will also need to add two other files. `userChrome.xml` and `userChrome.js`.
We will go over what needs to be done in `userChrome.js` but for `userChrome.xml` add the below content.

```xml
<?xml version="1.0"?>
<!-- Copyright (c) 2017 Haggai Nuchi
Available for use under the MIT License:
https://opensource.org/licenses/MIT
 -->

<!-- Run userChrome.js/userChrome.xul and .uc.js/.uc.xul/.css files  -->
<bindings xmlns="http://www.mozilla.org/xbl">
    <binding id="js">
        <implementation>
            <constructor><![CDATA[
                if(window.userChromeJsMod) return;
                window.userChromeJsMod = true;
                var chromeFiles = FileUtils.getDir("UChrm", []).directoryEntries;
                var xulFiles = [];
                var sss = Cc['@mozilla.org/content/style-sheet-service;1'].getService(Ci.nsIStyleSheetService);
                while(chromeFiles.hasMoreElements()) {
                    var file = chromeFiles.getNext().QueryInterface(Ci.nsIFile);
                    var fileURI = Services.io.newFileURI(file);
                    if(file.isFile()) {
                        type = "none";
                        if(/(^userChrome|\.uc)\.js$/i.test(file.leafName)) {
                            type = "userchrome/js";
                        }
                        else if(/(^userChrome|\.uc)\.xul$/i.test(file.leafName)) {
                            type = "userchrome/xul";
                        }
                        else if(/\.as\.css$/i.test(file.leafName)) {
                            type = "agentsheet";
                        }
                        else if(/^(?!(userChrome|userContent)\.css$).+\.css$/i.test(file.leafName)) {
                            type = "usersheet";
                        }
                        if(type != "none") {
                            console.log("----------\\ " + file.leafName + " (" + type + ")");
                            try {
                                if(type == "userchrome/js") {
                                    Services.scriptloader.loadSubScriptWithOptions(fileURI.spec, {target: window, ignoreCache: true});
                                }
                                else if(type == "userchrome/xul") {
                                    xulFiles.push(fileURI.spec);
                                }
                                else if(type == "agentsheet") {
                                    if(!sss.sheetRegistered(fileURI, sss.AGENT_SHEET))
                                        sss.loadAndRegisterSheet(fileURI, sss.AGENT_SHEET);
                                }
                                else if(type == "usersheet") {
                                    if(!sss.sheetRegistered(fileURI, sss.USER_SHEET))
                                        sss.loadAndRegisterSheet(fileURI, sss.USER_SHEET);
                                }
                            } catch(e) {
                                console.log("########## ERROR: " + e + " at " + e.lineNumber + ":" + e.columnNumber);
                            }
                            console.log("----------/ " + file.leafName);
                        }
                    }
                }
                setTimeout(function loadXUL() {
                    if(xulFiles.length > 0) {
                        document.loadOverlay(xulFiles.shift(), null);
                        setTimeout(loadXUL, 5);
                    }
                }, 0);
            ]]></constructor>
        </implementation>
    </binding>
</bindings>
```

### Setting up `userChrome.js`

Now finally we have to add in the code to change Firefox settings.

Add the below code in `userChrome.js` but replace the value of `mypage` to the location of your `index.html` file.

```js
(function() {
  // IMPORTANT: when there's no filename, be sure to include a trailing slash at the end.
  const mypage = "file:///Users/meain/Documents/Projects/projects/startpage/index.html";
  // Don't place the caret in the location bar. Useful if you want a page's search box to have focus instead.
  var removefocus = "no";
  // Clear the page's URL from the location bar. Normally not needed, as this should already be the default behavior.
  var clearlocationbar = "no";

  aboutNewTabService.newTabURL = mypage;
  function customNewTab () {
    if (removefocus == "yes") {
      setTimeout(function() {
        gBrowser.selectedBrowser.focus();
      }, 0);
    }
    if (clearlocationbar == "yes") {
      setTimeout(function() {
        if (gBrowser.selectedBrowser.currentURI.spec == mypage) {
          window.document.getElementById("urlbar").value = "";
        }
      }, 1000);
    }
  }
  gBrowser.tabContainer.addEventListener("TabOpen", customNewTab, false);

}());
```

Restart Firefox and you should be good to go.
If you need a good startpage, feel free to check out mine at [meain/startpage](https://github.com/meain/startpage).

### Extra

Well, you could use `userChrome.css` and `userChrome.js` for more than just this.
Here are a few websites you might wanna check out if you would like to know more what they can do.

- [userchrome.org](https://www.userchrome.org/)
- [luke-baker.github.io](https://luke-baker.github.io/)
- [alice0775/userChrome.js](https://github.com/alice0775/userChrome.js/)
