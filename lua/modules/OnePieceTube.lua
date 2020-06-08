----------------------------------------------------------------------------------------------------
-- Local Constants
----------------------------------------------------------------------------------------------------

local DirectoryPagination = '/'   --> Override template variable by uncommenting this line.

----------------------------------------------------------------------------------------------------
-- Event Functions
----------------------------------------------------------------------------------------------------

-- Get info and chapter list for current manga.
function GetInfo()
	local u = MaybeFillHost(MODULE.RootURL, URL)

	if not HTTP.GET(u) then return net_problem end

	x = CreateTXQuery(HTTP.Document)
	MANGAINFO.Title     = x.XPathString('//div[@id="breadcrumbs"]/substring-before(substring-after(., "Start"), "|")'):gsub('^%s*(.-)%s*$', '%1')
	MANGAINFO.Summary   = x.XPathString('//table[@class="infobox"]//tr[6]//td[2]')

	local v for v in x.XPath('//table[@class="list"]//tr[./td/@onclick|./td[2]]').Get() do
		MANGAINFO.ChapterNames.Add(x.XPathString('string-join((td[1],td[2])," ")', v))
		if MANGAINFO.Title == "Kapitel" then
			-- remove last /1 for quick getimageurl later
			MANGAINFO.ChapterLinks.Add(x.XPathString('td[@onclick]/substring-before(substring-after(@onclick, "\'"),"\'")', v):gsub('/1$',''))
		else
			-- remove last /1 for quick getimageurl later
			MANGAINFO.ChapterLinks.Add(x.XPathString('substring-before(substring-after(@onclick, "\'"),"\'")', v):gsub('/1$',''))
		end
	end

	return no_error
end

-- Get the page count of the manga list of the current website.
function GetDirectoryPageNumber()
	return no_error
end

-- Get LINKS and NAMES from the manga list of the current website.
-- DirectoryPagination = RootURL + Manga List
function GetNameAndLink()
	local v, x = nil
	local u = MODULE.RootURL .. DirectoryPagination

	if not HTTP.GET(u) then return net_problem end

	x = CreateTXQuery(HTTP.Document)
	v = x.XPath('//div[@id="mangalist"]//a[not(@id="SpinOffOpen")]')

	for i = 1, v.Count do
		LINKS.Add(MODULE.RootURL .. x.XPathString('@href', v.Get(i)))
		NAMES.Add(x.XPathString('text()', v.Get(i)))
	end

	return no_error
end

-- Get the page count for the current chapter.
function GetPageNumber()
	if HTTP.GET(MaybeFillHost(MODULE.RootURL,URL) .. '/1') then
		x=CreateTXQuery(HTTP.Document)
		-- get total page number
		TASK.PageNumber = tonumber(x.XPathString('//td[@id="tablecontrols"]/a[last()]')) or 0
		-- first page image URL
		TASK.PageLinks.Add(x.XPathString('//img[@id="p"]/@src'))
		return true
	else
		return false
	end
end

function GetImageURL()
	if HTTP.GET(MaybeFillHost(MODULE.RootURL, URL):gsub('/+$', '') .. '/' .. (WORKID + 1)) then
		TASK.PageLinks[WORKID] = CreateTXQuery(HTTP.Document).XPathString('//img[@id="p"]/@src')
		return true
	else
		return false
	end
end

----------------------------------------------------------------------------------------------------
-- Module Initialization
----------------------------------------------------------------------------------------------------

function Init()
	local m = NewWebsiteModule()
	m.ID                       = '4c3fb549e0de4a1cbad85869d3d79ef7'
	m.Name                     = 'OnePiece-Tube'
	m.RootURL                  = 'https://onepiece-tube.com'
	m.Category                 = 'German'
	m.OnGetInfo                = 'GetInfo'
	m.OnGetDirectoryPageNumber = 'GetDirectoryPageNumber'
	m.OnGetNameAndLink         = 'GetNameAndLink'
	m.OnGetPageNumber          = 'GetPageNumber'
	m.OnGetImageURL            = 'GetImageURL'
end