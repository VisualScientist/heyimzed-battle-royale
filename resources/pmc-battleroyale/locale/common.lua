_G.Locales = {}
_G._SELECTED_LOCALE = (GetResourceMetadata(GetCurrentResourceName(), 'locale', 0) or 'en'):lower()
_G._CURRENT_LOCALE = 'en'
_G._CURRENT_LOCALE_NAME = ''

function locale(_ln)
	_ln = _ln:lower()
	_CURRENT_LOCALE = _ln
	if Locales[_ln] == nil then Locales[_ln] = {} end
end

function set(_lnb)
	_CURRENT_LOCALE_NAME = _lnb
	return function(_lb)
		Locales[_CURRENT_LOCALE][_CURRENT_LOCALE_NAME] = _lb
	end
end

function _U(_ln, ...)
	local _l = Locales[_SELECTED_LOCALE][_ln]
	if _l ~= nil then
		return (_l):format(...)
	else
		return ("The locale [%s] '%s' not exists"):format(_SELECTED_LOCALE, _ln)
	end
end
