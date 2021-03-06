import os
from pyTuttle import tuttle
from multiprocessing.pool import ThreadPool
import logging


class ThumbnailUtil(object):
    """
    Helper class used to link buttle with tuttle for thumbnail functions
    """
    def __init__(self):
        tuttle.core().preload(False)
        self._thumbnailCache = tuttle.ThumbnailDiskCache()
        self._thumbnailCache.setRootDir(os.path.join(tuttle.core().getPreferences().getTuttleHomeStr(), "thumbnails_cache"))

    def getThumbnail(self, idPath):
        return self._thumbnailCache.getThumbnail(idPath)

    def getThumbnailPath(self, idPath):
        return self._thumbnailCache.getThumbnailPath(idPath)


# Concentrates in one point every compute process for thumbnail:
# Limits the thread and processes used for thumbnail processes

totalCpu = os.cpu_count()
useCpu = totalCpu - 2 if totalCpu > 3 else 1
logging.info('%d cpu used fot thumbnail creation', useCpu)

thumbnailPool = ThreadPool(processes=useCpu)