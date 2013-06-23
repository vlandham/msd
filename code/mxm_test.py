#!/usr/bin/env python

import sqlite3

conn = sqlite3.connect('data/mxm_dataset.db')

res = conn.execute("SELECT * FROM sqlite_master WHERE type='table'")
res.fetchall()

res = conn.execute("SELECT word FROM words")
len(res.fetchall())

res = conn.execute("SELECT word FROM words WHERE ROWID=4703")
res.fetchone()[0]

conn_tmdb = sqlite3.connect('data/track_metadata.db')

res = conn.execute("SELECT track_id FROM lyrics WHERE word='pretty'")
len(res.fetchall())

res = conn.execute("SELECT track_id FROM lyrics WHERE word='pretti'")
len(res.fetchall())

res = conn.execute("SELECT track_id FROM lyrics WHERE word='pretti' ORDER BY RANDOM() LIMIT 1")
res.fetchone()[0]

res = conn_tmdb.execute("SELECT artist_name, title FROM songs WHERE track_id='TRTCZAW128F1456003'")
res.fetchone()

res = conn.execute("SELECT word, count FROM lyrics WHERE track_id='TRTCZAW128F1456003' ORDER BY count DESC")
res.fetchall()

res = conn.execute("SELECT is_test FROM lyrics WHERE track_id='TRTCZAW128F1456003'")
res.fetchone()[0]

conn.close()
conn_tmdb.close()
