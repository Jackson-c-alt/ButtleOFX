from PySide import QtCore


class Int3DWrapper(QtCore.QObject):
    """
        Gui class, which maps a ParamInt3D.
    """

    def __init__(self, param):
        QtCore.QObject.__init__(self)
        self._param = param
        self._param.changed.connect(self.emitChanged)

    #################### getters ####################

    def getParamType(self):
        return self._param.setParamType()

    def getDefaultValue1(self):
        return self._param.setDefaultValue1()

    def getDefaultValue2(self):
        return self._param.setDefaultValue2()

    def getDefaultValue3(self):
        return self._param.setDefaultValue3()

    def getValue1(self):
        return self._param.setValue1()

    def getValue2(self):
        return self._param.setValue2()

    def getValue3(self):
        return self._param.setValue3()

    def getMaximum(self):
        return self._param.setMaximum()

    def getMinimum(self):
        return self._param.setMinimum()

    def getText(self):
        return self._param.setText()

    #################### setters ####################

    def setParamType(self, paramType):
        self._param.setParamType(paramType)

    def setDefaultValue1(self, defaultValue):
        self._param.setDefaultValue1(defaultValue)

    def setDefaultValue2(self, defaultValue):
        self._param.setDefaultValue2(defaultValue)

    def setDefaultValue3(self, defaultValue):
        self._param.setDefaultValue3(defaultValue)

    def setValue1(self, value):
        self._param.setValue1(value)

    def setValue2(self, value):
        self._param.setValue2(value)

    def setValue3(self, value):
        self._param.setValue3(value)

    def setMaximum(self, maximum):
        self._param.setMaximum(maximum)

    def setMinimum(self, minimum):
        self._param.setMinimum(minimum)

    def setText(self, text):
        self._param.setText(text)

    @QtCore.Signal
    def changed(self):
        pass

    def emitChanged(self):
        self.changed.emit()

    ################################################## DATA EXPOSED TO QML ##################################################

    paramType = QtCore.Property(unicode, getParamType, setParamType, notify=changed)
    text = QtCore.Property(unicode, getText, setText, notify=changed)
    value1 = QtCore.Property(int, getValue1, setValue1, notify=changed)
    value2 = QtCore.Property(int, getValue2, setValue2, notify=changed)
    value3 = QtCore.Property(int, getValue3, setValue3, notify=changed)
    maximum = QtCore.Property(int, getMaximum, setMaximum, notify=changed)
    minimum = QtCore.Property(int, getMinimum, setMinimum, notify=changed)
