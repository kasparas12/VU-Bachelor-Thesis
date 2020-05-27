CREATE TRIGGER [dbo].[InsteadOfUPDATEIsActive] on [dbo].[agent_registrar] FOR UPDATE AS
DECLARE @InsertedIsActive bit;
DECLARE @InsertedId int;
DECLARE @MaxCrawlingLimit int;
DECLARE @CurrentlyActiveAgents int;
     SELECT @InsertedId = INSERTED.id, @InsertedIsActive = INSERTED.is_active    
       FROM INSERTED

-- Patikriname, ar bandoma agentą padaryti aktyvų
IF UPDATE(is_active)
BEGIN
    -- Gauname peržiūros limitą, esantį nustatymų lentoje
	SELECT @MaxCrawlingLimit = CONVERT(INT,setting_value) FROM dbo.settings S WHERE S.setting_name = 'crawling_agents_limit'

    -- Patikriname, kiek šiuo metu užregistruota aktyvių peržiūros agentų
	SELECT @CurrentlyActiveAgents = COUNT(*) FROM dbo.agent_registrar D WHERE D.is_active = 1 AND D.is_deleted = 0


	IF @CurrentlyActiveAgents > @MaxCrawlingLimit
		THROW 51000, 'Agents Limit Exceeded!', 1; 
END