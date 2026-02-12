local ADDON_NAME, private = ...
if type(private) ~= "table" then
	private = {}
end

local current = (type(_G.GetLocale) == "function" and _G.GetLocale()) or "enUS"
if current == "enGB" then
	current = "enUS"
end

private._locales = private._locales or {
	current = current,
	default = nil,
	locales = {},
}
private._locales.current = current

function private:NewLocale(locale, isDefault)
	if type(locale) ~= "string" or locale == "" then return nil end
	local store = private._locales

	if isDefault then
		store.default = store.default or {}
		store._cachedLocale = nil
		store._cachedCurrent = nil
		store._cachedDefault = nil
		return store.default
	end

	if locale ~= store.current then
		return nil
	end

	store.locales[locale] = store.locales[locale] or {}
	store._cachedLocale = nil
	store._cachedCurrent = nil
	return store.locales[locale]
end

local function BuildLocale(store)
	local L = store.locales[store.current] or store.default or {}
	if store.default and L ~= store.default then
		if getmetatable(L) == nil then
			setmetatable(L, { __index = store.default })
		end
	end
	return L
end

function private:GetLocale()
	local store = private._locales
	if store._cachedLocale
		and store._cachedCurrent == store.current
		and store._cachedDefault == store.default
	then
		return store._cachedLocale
	end

	store._cachedCurrent = store.current
	store._cachedDefault = store.default
	store._cachedLocale = BuildLocale(store)
	return store._cachedLocale
end

private.L = private.L or setmetatable({}, {
	__index = function(_, key)
		return (private:GetLocale() or {})[key]
	end,
})
