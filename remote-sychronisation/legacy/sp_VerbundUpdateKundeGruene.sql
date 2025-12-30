USE [Apobase]
GO

/****** Object:  StoredProcedure [dbo].[sp_VerbundUpdateKundeGruene]    Script Date: 11.07.2025 17:45:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerbundUpdateKundeGruene]
	-- Add the parameters for the stored procedure here
	@diKdNr int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   UPDATE RemoteTable
   SET [RemoteTable].[strVorname] = [LocalTable].[strVorname]
      ,[RemoteTable].[strZwVorname] = [LocalTable].[strZwVorname]
      ,[RemoteTable].[strName] = [LocalTable].[strName]
      ,[RemoteTable].[strTitel] = [LocalTable].[strTitel]
      ,[RemoteTable].[strAnrede] = [LocalTable].[strAnrede]
      ,[RemoteTable].[strStrasse] = [LocalTable].[strStrasse]
      ,[RemoteTable].[diPlz] = [LocalTable].[diPlz]
      ,[RemoteTable].[strOrt] = [LocalTable].[strOrt]
      ,[RemoteTable].[strPlz] = [LocalTable].[strPlz]
      ,[RemoteTable].[strTelNrP] = [LocalTable].[strTelNrP]
      ,[RemoteTable].[strTelNrB] = [LocalTable].[strTelNrB]
      ,[RemoteTable].[strTelNrM] = [LocalTable].[strTelNrM]
      ,[RemoteTable].[strFaxNr] = [LocalTable].[strFaxNr]
      ,[RemoteTable].[strEmail] = [LocalTable].[strEmail]
      ,[RemoteTable].[diGebDat] = [LocalTable].[diGebDat]
      ,[RemoteTable].[strNotPers] = [LocalTable].[strNotPers]
      ,[RemoteTable].[strNotTelNr] = [LocalTable].[strNotTelNr]
      ,[RemoteTable].[bRabattEk] = [LocalTable].[bRabattEk]
      ,[RemoteTable].[iRabatt] = [LocalTable].[iRabatt]
      ,[RemoteTable].[iRabatt2] = [LocalTable].[iRabatt2]
      ,[RemoteTable].[iRabatt3] = [LocalTable].[iRabatt3]
      ,[RemoteTable].[iRabatt4] = [LocalTable].[iRabatt4]
      ,[RemoteTable].[strVersNr] = [LocalTable].[strVersNr]
      ,[RemoteTable].[diKKNr] = [LocalTable].[diKKNr]
      ,[RemoteTable].[diBefrBisDat] = [LocalTable].[diBefrBisDat]
      ,[RemoteTable].[diGltBisDat] = [LocalTable].[diGltBisDat]
      ,[RemoteTable].[cStatus] = [LocalTable].[cStatus]
      ,[RemoteTable].[iKuKaNr] = [LocalTable].[iKuKaNr]
      ,[RemoteTable].[cKuKaStat] = [LocalTable].[cKuKaStat]
      ,[RemoteTable].[bMonatsAbr] = [LocalTable].[bMonatsAbr]
      ,[RemoteTable].[bQuartAbr] = [LocalTable].[bQuartAbr]
      ,[RemoteTable].[bJahresAbr] = [LocalTable].[bJahresAbr]
      ,[RemoteTable].[bNichtSammel] =[LocalTable].[bNichtSammel]
      ,[RemoteTable].[bNichtEinzel] = [LocalTable].[bNichtEinzel]
      ,[RemoteTable].[bAbbuchung] = [LocalTable].[bAbbuchung]
      ,[RemoteTable].[bAllergiker] = [LocalTable].[bAllergiker]
      ,[RemoteTable].[bKonto] = [LocalTable].[bKonto]
      ,[RemoteTable].[bMed] = [LocalTable].[bMed]
      ,[RemoteTable].[bNotiz] = [LocalTable].[bNotiz]
      ,[RemoteTable].[strHausarzt] = [LocalTable].[strHausarzt]
      ,[RemoteTable].[strNotiz] = [LocalTable].[strNotiz]
      ,[RemoteTable].[bSchnellerfassung] = [LocalTable].[bSchnellerfassung]
      ,[RemoteTable].[bytGeschlecht] = [LocalTable].[bytGeschlecht]
      ,[RemoteTable].[strInternet] = [LocalTable].[strInternet]
      ,[RemoteTable].[strKKNummer] = [LocalTable].[strKKNummer]
      ,[RemoteTable].[diKdNrHpt] = [dbo].[FKT_TranslateKdNrToGruene]([LocalTable].[diKdNrHpt])
      ,[RemoteTable].[bMedNurAkt] = [LocalTable].[bMedNurAkt]
      ,[RemoteTable].[bRabInVg] = [LocalTable].[bRabInVg]
      ,[RemoteTable].[bNoInteraktionsCheck] = [LocalTable].[bNoInteraktionsCheck]
      ,[RemoteTable].[bHausapotheke] = [LocalTable].[bHausapotheke]
      ,[RemoteTable].[cStdRpStatusInVg] = [LocalTable].[cStdRpStatusInVg]
      ,[RemoteTable].[bBefreiungGueltig] =[LocalTable].[bBefreiungGueltig]
      ,[RemoteTable].[diKdNrRechnung] = [dbo].[FKT_TranslateKdNrToGruene]([LocalTable].[diKdNrRechnung])
      ,[RemoteTable].[strZahlungsziel] = [LocalTable].[strZahlungsziel]
      ,[RemoteTable].[strBank] = [LocalTable].[strBank]
      ,[RemoteTable].[strBlz] = [LocalTable].[strBlz]
      ,[RemoteTable].[strKtNr] = [LocalTable].[strKtNr]
      ,[RemoteTable].[bFragen1] = [LocalTable].[bFragen1]
      ,[RemoteTable].[bFragen2] = [LocalTable].[bFragen2]
      ,[RemoteTable].[bFragen3] = [LocalTable].[bFragen3]
      ,[RemoteTable].[bFragen4] = [LocalTable].[bFragen4]
      ,[RemoteTable].[bJahresrabatt] = [LocalTable].[bJahresrabatt]
      ,[RemoteTable].[bChargenabfrage] = [LocalTable].[bChargenabfrage]
      ,[RemoteTable].[bBonusmodell] = [LocalTable].[bBonusmodell]
      ,[RemoteTable].[bBlister] = [LocalTable].[bBlister]
      ,[RemoteTable].[strPaybackKdNr] = [LocalTable].[strPaybackKdNr]
      ,[RemoteTable].[bKKNrIsPayback] = [LocalTable].[bKKNrIsPayback]
      ,[RemoteTable].[bGeloescht] = [LocalTable].[bGeloescht]
      ,[RemoteTable].[bNoHistorie] = [LocalTable].[bNoHistorie]
      ,[RemoteTable].[byDSE] = [LocalTable].[byDSE]
      ,[RemoteTable].[strBIC] = [LocalTable].[strBIC]
      ,[RemoteTable].[strIBAN] = [LocalTable].[strIBAN]
      ,[RemoteTable].[strMandatsRefNr] = [LocalTable].[strMandatsRefNr]
      ,[RemoteTable].[cAbbuchungsermaechtigung] = [LocalTable].[cAbbuchungsermaechtigung]
      ,[RemoteTable].[cEinverstaendniserklaerung] = [LocalTable].[cEinverstaendniserklaerung]
      ,[RemoteTable].[dwEinverstaendniserklaerung] = [LocalTable].[dwEinverstaendniserklaerung]
      ,[RemoteTable].[dwAbbuchungsermaechtigung] = [LocalTable].[dwAbbuchungsermaechtigung]
      ,[RemoteTable].[strVerwendungszweck1] = [LocalTable].[strVerwendungszweck1]
      ,[RemoteTable].[strVerwendungszweck2] = [LocalTable].[strVerwendungszweck2]
      ,[RemoteTable].[strVerwendungszweck3] = [LocalTable].[strVerwendungszweck3]
      ,[RemoteTable].[bOhneVerkaufStatistik] = [LocalTable].[bOhneVerkaufStatistik]
      ,[RemoteTable].[strAdresszusatz] = [LocalTable].[strAdresszusatz]
	  FROM 
		[192.168.114.101\SQLEXPRESS].[Apobase].[dbo].[RW_APOBASE_Kunde] AS RemoteTable
		INNER JOIN 
		[dbo].[RW_APOBASE_Kunde] AS LocalTable
		ON 
			[dbo].[FKT_TranslateKdNrToGruene](LocalTable.diKdNrAuto) = RemoteTable.diKdNrAuto
		WHERE LocalTable.diKdNrAuto = @diKdNr

END

GO


