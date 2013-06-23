#!/usr/bin/env python

import sqlite3
conn_meta = sqlite3.connect('./data/track_metadata.db')

res = conn_meta.execute("SELECT * FROM sqlite_master WHERE type='table'")
print res.fetchall()
