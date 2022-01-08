-- ranks/ranks.lua

ranks.register("admin", {
	prefix = "Admin",
	colour = {a = 255, r = 230, g = 33, b = 23},
	-- Prevents rank from being granted additional privs.
	revoke_extra = false,
	-- If members of this rank are missing privileges, grant them.
	grant_missing = true,
	-- Equivalent to revoke_extra=true + grant_missing=true
	strict_privs = false,
	privs = {
	   grant = true
	}
})
