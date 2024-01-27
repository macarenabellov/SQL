1)	First, I’d like to show our volume growth. Can you pull overall session and order volumen, trended by quarter for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.

SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;
2)	Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we launched, for session-to-order conversion rate, revenue per order, and revenue per session.
SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate,
    SUM(price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2;
-- Is a great story for the business where session to order conv_rate has increased during the time. (started on 0.0320 and ended up with 0.844). The same happened with revenue per order and per session, they increased impressively.


3)	 I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, Brand search overall, organic search, and direct type-in?

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;
-- We see tremendous growth in all of these channels. The business has become much less dependent on these paid gsearch non brand campaign and starting to really bill is brand, organic and direct type in orders, which has better margin. Investors will really appreciate this.


4)	Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. Please also make a note of any periods where we made major improvements or optimizations.

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rt,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rt,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END)
    /COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

-- the gsearch conv rate started on 3% and increased to 8,6%, more than double of conversion rate. Same with bsearch_nonbrand convertion rate.
-- On the other hand brand search, organic search and direct type in have been increasing in the same rythim, from zero to between 7,75% to 8,52%. The business have been increasing all the time.


5)	We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2
;
-- We see that revenue in general have been increasing during the time. Peaks of revenue are in months 11 and 12, but later in months 1 and 2 we see an important drop.


6)	Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time, along with a view of how conversion from /products to placing and order has improved.
-- first, identifying all the views of the /products page

CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at

FROM website_pageviews
WHERE pageview_url = '/products'
;

SELECT
	YEAR(saw_product_page_at) AS yr,
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_Order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pageviews.website_session_id -- same session
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id -- they had another page AFTER
	LEFT JOIN orders
		ON orders.website_session_id = products_pageviews.website_session_id
	GROUP BY 1, 2;
  
-- General growth in the sessions of the product page, and the clickthrough rate going up from around 70% to 85% in the most recent month, and the products to order rate going up from 8% to 13,9%.
-- Adding new products has affected in a positive way to help to contribute to the health of the business.


7)	We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). Could you please pull sales data since then, and show how well each producto cross-sells from one another?

CREATE TEMPORARY TABLE primary_products
SELECT
	order_id,
    primary_product_id,
    created_at AS ordered_at
FROM orders
WHERE created_at > '2014-12-05'; -- when the 4th product was added (says so in question)

SELECT
	primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
	COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM
(
SELECT
	primary_products.*,
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0 -- only bringing in cross-sells
	) AS primary_w_cross_sell
    GROUP BY 1
    
--  We see that product 4 cross very well with all of the products, and product 3 cross well with product 2. 
-- It seems that adding product 4 at that lower price point was probably a good thing for the business and maybe a major contributor to higher order average value.

8)	In addition to telling investors about what we’ve already achieved, let’s show them that we still have plenty of gas in the tank. Based on all the analysis you’ve done, could you share some recommendations and opportunities for us going forward? No right or wrong answer here – I’d just like to hear your perspective!
-- Different areas of the website where I still see drop off. Also continue to add additional products similar to some of the products that cross sold really well or that have been really additive to the business when we’ve launched them.
