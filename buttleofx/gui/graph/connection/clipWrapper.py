from PySide import QtCore


class ClipWrapper(QtCore.QObject):

    """
        Class ClipWrapper
    """

    def __init__(self, clipName, nodeName, view):
        super(ClipWrapper, self).__init__(view)
        self._nodeName = nodeName
        self._clipName = clipName

    def getNodeName(self):
        return self._nodeName

    def getName(self):
        return self._clipName

    name = QtCore.Property(unicode, getName, constant=True)