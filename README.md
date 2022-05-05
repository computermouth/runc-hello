`make` will produce:
  - binary `runc-hello`
  - target rootfs `rootfs`
  - distributable tar.gz `runc-hello.tar.gz`
  
web application will:
  - consume url of `runc-hello.tar.gz`
  - forward url to the client-side download server
  - get a 200 from client-side download server

download server will:
  - fetch from url (if error, such as interrupted download, delete partial)
  - unpack tarball to a directory of name `md5sum runc-hello.tar.gz` (on error, delete tarball and dir)
  - os.Exec("runc create -b ${md5} ${md5}") -- validates config.json -- creates container named after dir (deletes again on failure)
  - rm -rf `runc-hello.tar.gz` (only used for distribution)

future features??:
  - before download server returns 200, create new api endpoint for webapp to read status of install
    - web {"install":"URL"} -> download-server
    - download-server (create new api endpoint, md5sum url?, populate with status {"state": "fetch", "fetch":"00", "status":"ok"})
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"00",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"10",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"20",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"30",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"40",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"40",  "status":"failed"}
    - download-server -- unregister api endpoint
    - web updates to show failure, try again?
    - web {"install":"URL"} -> download-server
    - download-server (create new api endpoint, md5sum url?, populate with status {"state": "fetch":"00", "status":"ok"})
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"00",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"10",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"20",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"30",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"40",  "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "fetch", "fetch":"100", "status":"ok"}
    - web GET http://download-server/${url_md5} -> 200 {"state": "unpack", "status":"ok"} ## not really any way to show progress here
    - web GET http://download-server/${url_md5} -> 200 {"state": "unpack", "status":"ok"} ## not really any way to show progress here
    - web GET http://download-server/${url_md5} -> 200 {"state": "unpack", "status":"ok"} ## not really any way to show progress here
    - web GET http://download-server/${url_md5} -> 200 {"state": "unpack", "status":"ok"} ## not really any way to show progress here
    - web GET http://download-server/${url_md5} -> 200 {"state": "create", "status":"ok"} ## not really any way to show progress here
    - web GET http://download-server/${url_md5} -> 200 {"state": "cleanup", "status":"ok"} ## not really any way to show progress here
    - web GET http://download-server/${url_md5} -> 200 {"state": "sync", "status":"ok"} ## not really any way to show progress here
    - web GET http://download-server/${url_md5} -> 200 {"state": "complete", "status":"ok"}
    - download-server -- unregister api endpoint

all the while, updating web ui


PC-browser
===============================
required -- meta tag
<meta http-equiv="Content-Security-Policy" content="default-src *; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'">
NOTE: meta tag, may or may not require IP/domain at end of tag
NOTE: will have to hit 256 IP addresses, choose the first that returns 200

DEVICE
===============================
must have??

add_header Access-Control-Allow-Origin *;

DIAGRAM
===============================

      PC  -  192.168.0.11                                    Handheld   - 192.168.172.11

      ┌──────────────────────────────────┐                   ┌─────────────────────────────────┐
      │  Browser: crunchi.com/somegame   │                   │   Device: golang server         │
      │ ┌──────────────────────────────┐ │                   │                                 │
      │ │                              │ │                   │  ┌────────────────────────────┐ │
      │ │SOMEGAME!                     │ │                   │  │ /games                     │ │
      │ │                              │ │ USB(eth0)         │  │ /games/new                 │ │
      │ │like doom,                    │ │                   │  │ /games/[id]/status         │ │
      │ │but not.     ┌──────────────┐ │ ├─────────────────► │  │                            │ │
      │ │             │ INSTALL      │ │ │                   │  │                            │ │
      │ │             └┬─────────────┘ │ │ ◄─────────────────┤  │                            │ │
      │ │              │               │ │                   │  └──────┬─────────────────────┘ │
      │ └──────────────┼───────────────┘ │                   │         │                       │
      │                │                 │                   │  ┌──────▼─────────────────────┐ │
      │  ┌─────────────┴───────────────┐ │                   │  │Filesystem: ~/              │ │
      │  │.js                          │ │                   │  │                            │ │
      │  │                             │ │                   │  │ some.tar.gz                │ │
    id│= │http.post(g_url, 192.168.172.11/games/new)         │  │ some_abcdefgabcdef         │ │
    st│= │http.get(192.168.172.11/games/$id/status)          │  │ fart_bcdefgabcdefg         │ │
      │  │div(progress)=st.percent     │ │                   │  │ cool_cdefgabcdefga         │ │
      │  └─────────────────────────────┘ │                   │  └────────────────────────────┘ │
      │                                  │                   │                                 │
      └──────────────────────────────────┘                   └─────────────────────────────────┘
