SELECT 
    cam.jobNumber,
    cam.displayName,
    med.dateStart,

    SUM(med.impressions) AS PlannedImpressions,
    SUM(med.clientPriceTotalDiscountTwoCzk) AS PlannedMediaInvestment,
    (SUM(med.clientPriceTotalDiscountTwoCzk) / NULLIF(SUM(med.impressions), 0)) * 1000 AS PlannedCpt,

    SUM(pb.impressions) AS RealImpressions,
    SUM(pb.mediaCostsDiscountTwoCzk) AS RealMediaInvestment,
    (SUM(pb.mediaCostsDiscountTwoCzk) / NULLIF(SUM(pb.impressions), 0)) * 1000 AS RealCpt,

    SUM(med.views) AS PlanViews,
    (SUM(med.clientPriceTotalDiscountTwoCzk) / NULLIF(SUM(med.views), 0)) AS PlannedCpv,

    SUM(pb.views) AS RealViews,
    (SUM(pb.mediaCostsDiscountTwoCzk) / NULLIF(SUM(pb.views), 0)) AS RealCpv,

    SUM(med.clicks) AS PlannedClicks,
    (SUM(med.clientPriceTotalDiscountTwoCzk) / NULLIF(SUM(med.clicks), 0)) AS PlannedCpc,

    SUM(pb.clicks) AS RealClicks,
    (SUM(pb.mediaCostsDiscountTwoCzk) / NULLIF(SUM(pb.clicks), 0)) AS RealCpc
FROM dbo.CampaignList cam 
JOIN dbo.MediaplanLineMetadata mm 
  ON cam.campaignId = mm.campaignId
JOIN dbo.MediaplanLineValues med 
  ON med.campaignId = mm.campaignId 
    AND med.lineId     = mm.lineId
JOIN dbo.PostbuyLineValues pb 
  ON pb.campaignId  = med.campaignId 
    AND pb.lineId      = med.lineId
    AND pb.dateStart   = med.dateStart
    AND pb.granularity  = med.granularity
WHERE cam.clientId = '196'  -- Samsung Client ID
  AND cam.campaignMediaTypeName = 'DIGITAL'
  AND cam.visibleToClient = 1
  AND YEAR(cam.campaignStarts) IN (2025, 2026)
  AND mm.isPrimary = 1  -- Eliminate Sublines
  AND pb.granularity  = 'Day'
  AND med.dateStart < CAST(GETDATE() AS date)
GROUP BY cam.jobNumber, cam.displayName, med.dateStart;
