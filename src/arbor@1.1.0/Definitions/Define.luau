-- Arbor/src/arbor@1.1.0/Definitions/Define.luau
--!strict

local Define = {}

--# Functions

function Define.Tag<Contract>(contract: Contract): Contract
	return contract
end

function Define.TypeFunction<Callback>(callback: Callback): Callback
	return callback
end

function Define.Chain<Steps>(steps: Steps): { chain: Steps }
	return {
		chain = steps,
	}
end

--# Return

return Define
