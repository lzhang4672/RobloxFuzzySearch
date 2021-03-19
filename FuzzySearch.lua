local module = {}
	local accuracy = 1.2
	local itemList = {};
	local includeIfOver = true
	for i = 1, 300 do 
		itemList[i] = {};
	end
	local matchedItems = {};
	local currentIndex = 1;
	local nowhitespace = false;
	function fuzzySearch(query, item)
		local LCS = 0; -- store the longest common subsequence
		local DP = {};
		for i = 1, 300 do -- fill up the 2d array.
			DP[i] = {}
		end
		if nowhitespace then 
			query = string.gsub(query, "%s+", "");
			item = string.gsub(item, "%s+", "");
		end
		query = string.lower(query)
		item = string.lower(item)
		for i = 1, string.len(query)+1 do
			for j = 1, string.len(item)+1 do
				if i == 1 or j == 1 then 
					DP[i][j] = 0; 
				elseif string.sub(query, i-1, i-1) == string.sub(item, j-1, j-1) then
					DP[i][j] = 1 + DP[i-1][j-1]; -- get previous cell's solution and add one.
				else
					DP[i][j] = math.max(DP[i][j-1], DP[i-1][j]); -- get largest LCS from previous cell and to this cell.
				end
			end
		end
		if DP[string.len(query)][string.len(item)] ~= nil then
			LCS = DP[string.len(query)+1][string.len(item)+1]
		end
		if (LCS ~= nil and LCS >= (string.len(query)/accuracy)) then
			return true
		else
			if includeIfOver then
				if (LCS >= string.len(item)) then
					return true
				end
			end
			return false
		end
	end
	function module:includeItemIfOver(val)
		if val then
			includeIfOver = true
			return
		end
		includeIfOver = false
	end
	function module:addItem(list)
		for _, j in pairs(list) do
			itemList[currentIndex][#itemList[currentIndex]+1] = j
		end
		currentIndex = currentIndex + 1;
	end
	function module:changeAccuracy(number)
		if number ~= nil and number >= 1 then
			accuracy = number
		else
			error("Please enter a valid number: changeAccuracy(number)")
			return
		end
	end

	function module:fuzzySearch(query, stripwhitespace)
		if stripwhitespace == nil then
			error("Please specify whether to strip white space or not. fuzzySearch(query, true/false)");
			return;
		end
		if query == nil then
			error("Please enter a valid query");
			return;
		end
		if stripwhitespace then 
			nowhitespace = true;
		else
			nowhitespace = false;
		end
		matchedItems = {};
		for i = 1, currentIndex-1 do
			for d = 1, #itemList[i] do
				if fuzzySearch(query, itemList[i][d]) then 
					if itemList[i][d] ~= nil then
						if #matchedItems == 0 then
							table.insert(matchedItems, itemList[i][1])
						else
							local matched = true
							for _, item in pairs(matchedItems) do 
								if item == itemList[i][1] then
									matched = false
									break
								end
							end 
							if matched then 
								table.insert(matchedItems, itemList[i][1])
							end
						end			
					end		
				end
			end
		end
		return matchedItems
	end

return module
