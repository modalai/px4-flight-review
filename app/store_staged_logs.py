#! /usr/bin/env python3
""" Copy uploads left in the staging directory (FLIGHT_REVIEW_STAGING) into the
log directory, e.g. after a restart interrupted the background copy. """

import os
import sys

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'plot_app'))
from plot_app.config import get_staging_filepath  # pylint: disable=wrong-import-position
from tornado_handlers.upload import store_staged_log  # pylint: disable=wrong-import-position

staging = get_staging_filepath()
if staging and os.path.isdir(staging):
    for name in sorted(os.listdir(staging)):
        if name.endswith('.ulg'):
            try:
                store_staged_log(name[:-4])
            except Exception as e:  # pylint: disable=broad-except
                print('Could not store', name, e)
