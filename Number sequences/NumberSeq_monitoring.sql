/*
	ONLY NEED THIS IN AN ALWAYSON HIGH AVAILABILITY GROUP,
	TO EXECUTE JOB ON PRIMARY REPLICA EXCLUSIVELY
*/

IF sys.fn_hadr_is_primary_replica(DB_NAME()) <> 1   
BEGIN  
-- If this is not the primary replica, exit
	RETURN
END  
-- If this is the primary replica, continue

/*
	MAIN PART FOR SELECTING NUMBER SEQUENCE CONSUMPTION
*/

DECLARE @tableHTML NVARCHAR(MAX);

SET @tableHTML =
    N'<H1>Number sequences consumed above threshold 70%</H1>' +
    N'<table border="1">' +
    N'<tr><th>Sequence</th><th>Text</th>' +
    N'<th>Min</th><th>Max</th><th>Next</th>' +
    N'<th>Percentage</th></tr>' +
    CAST ( ( SELECT td = [NUMBERSEQUENCE],''
				  ,td = [TXT],''
				  ,td = [LOWEST],''
				  ,td = [HIGHEST],''
				  ,td = [NEXTREC],''
				  ,td = CONVERT(NUMERIC, (CONVERT(REAL, ([NEXTREC]-[LOWEST]) / CONVERT(REAL, [HIGHEST]-[LOWEST] ))*100))
			  FROM [dbo].[NUMBERSEQUENCETABLE]
			  WHERE (NEXTREC - LOWEST) >= (HIGHEST - LOWEST) * 0.7
			  ORDER BY (CONVERT(REAL, ([NEXTREC]-[LOWEST]) / CONVERT(REAL, [HIGHEST]-[LOWEST] ))*100) DESC
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;

--select @tableHTML

EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'YOUREMAIL@ADDRE.SS',
    @subject = 'Number sequences consumed above threshold',
    @profile_name = 'YOURDATABASEMAILPROFILE',
    @attach_query_result_as_file=0,
    @execute_query_database = 'YOURAXDBNAME',
	@body_format = 'HTML',
	@body = @tableHTML;
