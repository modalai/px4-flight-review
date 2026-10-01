#! /usr/bin/env python3
""" Copy the local DB (FLIGHT_REVIEW_DB) into the storage path as logs.sqlite,
when it changed. The storage path may be a network mount (a bucket), so the
consistent snapshot is taken locally first and then copied in one write. """

import filecmp
import os
import shutil
import sqlite3
import sys

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'plot_app'))
from plot_app.config import get_db_filename, get_log_filepath  # pylint: disable=wrong-import-position

db_filename = get_db_filename()
stored = os.path.join(os.path.dirname(get_log_filepath()), 'logs.sqlite')
if os.path.abspath(db_filename) == os.path.abspath(stored):
    sys.exit(0)

snapshot = db_filename + '.snapshot'
last = db_filename + '.stored'
src = sqlite3.connect(db_filename)
dst = sqlite3.connect(snapshot)
with dst:
    src.backup(dst)
dst.close()
src.close()
if os.path.exists(last) and filecmp.cmp(snapshot, last, shallow=False):
    sys.exit(0)
shutil.copyfile(snapshot, stored)  # one object write on a bucket mount
os.replace(snapshot, last)
print('Stored DB backup in', stored)
