/* 1. Urutan benua berdasarkan jumlah company terbanyak. 
Benua mana yang memiliki unicorn paling banyak?*/
SELECT
	uc.continent,
	COUNT(DISTINCT uc.company_id) AS total_per_continent
FROM unicorn_companies uc
GROUP BY 1
ORDER BY 2 DESC

/* 2. Negara apa saja yang memiliki jumlah unicorn > 100 */
SELECT
	uc.country,
	COUNT(DISTINCT company_id) AS total_company
FROM unicorn_companies uc 
GROUP BY 1
HAVING COUNT(DISTINCT company_id) > 100
ORDER BY 2 DESC

/* 3. Industri yang paling besar diantara unicorn berdasarkan total funding.
Lalu rata2 valuasinya? */
SELECT
	ui.industry,
	SUM(uf.funding) AS total_funding,
	AVG(uf.valuation) AS average_valuation
FROM unicorn_industries ui
INNER JOIN unicorn_funding uf
	ON ui.company_id = uf.company_id
GROUP BY 1 ORDER BY 2 DESC

/* 4. Berapa jumlah company yang bergabung sebagai unicorn tiap tahunnya,
2016 - 2022 */
SELECT
	EXTRACT(YEAR FROM ud.date_joined) AS tahun_bergabung,
	COUNT(DISTINCT ud.company_id) AS total_company
FROM unicorn_dates ud
INNER JOIN unicorn_industries ui 
	ON ud.company_id = ui.company_id 
	AND ui.industry = 'Fintech' -- lakukan JOIN kalau memenuhi kondisi ini juga
WHERE EXTRACT(YEAR FROM ud.date_joined) BETWEEN 2016 AND 2022
GROUP BY 1

/* 5. Tampilkan data detail company (nama, kota, negara dan benua) beserta
industri dan valuasinya. Dari negara mana company dengan valuasi terbesar
berasal dan apa industrinya?

Bagaimana dgn Indo? Company apa yang memiliki valuasi paling besar di Indo?*/
SELECT
	uc.company,
	uc.city,
	uc.country,
	uc.continent,
	uf.valuation,
	ui.industry
FROM unicorn_companies uc
INNER JOIN unicorn_funding uf
	ON uc.company_id = uf.company_id
INNER JOIN unicorn_industries ui
	ON uc.company_id = ui.company_id
ORDER BY valuation DESC

SELECT
	uc.company,
	uc.city,
	uc.country,
	uc.continent,
	uf.valuation,
	ui.industry
FROM unicorn_companies uc
INNER JOIN unicorn_funding uf
	ON uc.company_id = uf.company_id
INNER JOIN unicorn_industries ui
	ON uc.company_id = ui.company_id
WHERE uc.country = 'Indonesia'
ORDER BY valuation DESC

/* 6. Berapa umur company tertua ketika company tersebut bergabung menjadi unicorn company?
Dari negara mana? */
SELECT
	uc.company,
	uc.country,
	EXTRACT(YEAR FROM ud.date_joined) - ud.year_founded AS umur_company
FROM unicorn_dates ud
INNER JOIN unicorn_companies uc
	ON ud.company_id = uc.company_id
ORDER BY umur_company DESC

/* 7. Company yg didirikan tahun 1960 - 2000, berapa umur company tertua
ketika bergabung menjadi unicorn? Dari mana negara asalnya? */
SELECT
	uc.company,
	uc.country,
	EXTRACT(YEAR FROM ud.date_joined) - ud.year_founded AS umur_company
FROM unicorn_dates ud 
INNER JOIN unicorn_companies uc
	ON ud.company_id = uc.company_id 
WHERE ud.year_founded BETWEEN 1960 AND 2000
ORDER BY umur_company DESC

/* 8. Ada brp company yg dibiayai oleh minimal 1 investor yang mengandung 
nama 'venture' 

Ada brp company yg dibiayai oleh minimal satu investor mengandung nama:
- Venture
- Capital
- Partner*/
SELECT
	COUNT(DISTINCT company_id) AS total_company
FROM unicorn_funding uf 
WHERE LOWER(uf.select_investors) LIKE '%venture%'

SELECT
	COUNT(DISTINCT company_id) AS total_company,
	COUNT(DISTINCT CASE WHEN LOWER(uf.select_investors) LIKE '%venture%' THEN uf.company_id END) AS total_company__venture,
	COUNT(DISTINCT CASE WHEN LOWER(uf.select_investors) LIKE '%capital%' THEN uf.company_id END) AS total_company__capital,
	COUNT(DISTINCT CASE WHEN LOWER(uf.select_investors) LIKE '%partner%' THEN uf.company_id END) AS total_company__partner
FROM unicorn_funding uf 

/* 9. Di Indo banyak startup bidang logistik. Ada brp startup logistik unicorn di Asia?
Berapa banyak startup logistik unicorn di Indo? */
SELECT
	COUNT(DISTINCT CASE WHEN uc.continent = 'Asia' THEN uc.company_id END) AS startup_logistik_asia,
	COUNT(DISTINCT CASE WHEN uc.country = 'Indonesia' THEN uc.company_id END) AS startup_logistik_indonesia
FROM unicorn_companies uc
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id 
WHERE ui.industry = '"Supply chain, logistics, & delivery"'

/* 10. Di Asia terdapat tiga negara dengan jumlah unicorn terbanyak. 
Tampilkan data jumlah unicorn di tiap industri dan negara asal di Asia, terkecuali tiga negara tersebut. 
Urutkan berdasarkan industri, jumlah company (menurun), dan negara asal.*/
SELECT
	ui.industry,
	uc.country,
	COUNT(DISTINCT uc.company_id) AS total_company
FROM unicorn_companies uc
INNER JOIN unicorn_industries ui
	ON uc.company_id = ui.company_id 
LEFT JOIN (
	SELECT
		uc1.country,
		COUNT(DISTINCT uc1.company_id) AS total_company
	FROM unicorn_companies uc1 
	WHERE uc1.continent = 'Asia'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 3
) top_3
	ON uc.country = top_3.country
WHERE uc.continent = 'Asia' AND top_3.country IS NULL
GROUP BY 1,2
ORDER BY 1,3 DESC,2

/* 11. Amerika Serikat, China, dan India adalah tiga negara dengan jumlah unicorn paling banyak. 
Apakah ada industri yang tidak memiliki unicorn yang berasal dari India? Apa saja?
*/
WITH industry_india AS (
SELECT
	DISTINCT ui.industry 
FROM unicorn_industries ui
INNER JOIN unicorn_companies uc 
	ON uc.company_id = ui.company_id 
	AND uc.country = 'India' 
)
SELECT
	DISTINCT ui.industry 
FROM unicorn_industries ui
LEFT JOIN industry_india ii
	ON ui.industry = ii.industry
WHERE ii.industry IS NULL

/* 12. Cari tiga industri yang memiliki paling banyak unicorn di tahun 2019-2021 
dan tampilkan jumlah unicorn serta rata-rata valuasinya (dalam milliar) di tiap tahun.
*/
WITH top_3 AS (
SELECT
	ui.industry,
	COUNT(DISTINCT ui.company_id)
FROM unicorn_industries ui 
INNER JOIN unicorn_dates ud 
	ON ui.company_id = ud.company_id 
WHERE EXTRACT(YEAR FROM ud.date_joined) IN (2019,2020,2021)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
),

yearly_rank AS (
SELECT
	ui.industry,
	EXTRACT(YEAR FROM ud.date_joined) AS year_joined,
	COUNT(DISTINCT ui.company_id) AS total_company,
	ROUND(AVG(uf.valuation)/1000000000,2) AS avg_valuation_billion
FROM unicorn_industries ui 
INNER JOIN unicorn_dates ud 
	ON ui.company_id = ud.company_id 
INNER JOIN unicorn_funding uf 
	ON ui.company_id = uf.company_id 
GROUP BY 1,2
)

SELECT
	y.*
FROM yearly_rank y
INNER JOIN top_3 t
	ON y.industry = t.industry
WHERE y.year_joined IN (2019,2020,2021)
ORDER BY 1,2 DESC

/* 13. Negara mana yang memiliki unicorn paling banyak 
(seperti pertanyaan nomor 1) dan berapa persen proporsinya?
*/
SELECT
	uc.country,
	COUNT(DISTINCT uc.company_id) AS total_per_country,
	(CAST(COUNT(DISTINCT uc.company_id) AS FLOAT) / CAST(COUNT(DISTINCT uc2.company_id) AS FLOAT))*100 AS pct_company
FROM unicorn_companies uc, unicorn_companies uc2 
GROUP BY 1
ORDER BY 2 DESC