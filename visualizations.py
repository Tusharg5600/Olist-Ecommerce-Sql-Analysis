import pandas as pd
import plotly.express as px
import os

# Create visuals folder if it doesn't exist
os.makedirs('visuals', exist_ok=True)

# ─────────────────────────────────────────────
# CHART 1 — Late Deliveries vs Review Scores
# ─────────────────────────────────────────────
df1 = pd.read_csv('results/delivery_vs_reviews.csv')

fig1 = px.bar(
    df1,
    x='delivery_status',
    y='avg_review_score',
    color='delivery_status',
    text='avg_review_score',
    title='Impact of Late Deliveries on Customer Review Scores',
    labels={
        'delivery_status': 'Delivery Status',
        'avg_review_score': 'Average Review Score (out of 5)'
    },
    color_discrete_map={
        'On Time': '#2ecc71',
        'Late': '#e74c3c'
    }
)

fig1.update_traces(texttemplate='%{text:.2f}', textposition='outside')
fig1.update_layout(
    showlegend=False,
    yaxis_range=[0, 5],
    plot_bgcolor='white',
    title_font_size=16
)

fig1.write_image('visuals/delivery_vs_reviews.png')
fig1.write_html('visuals/delivery_vs_reviews.html')
print("Chart 1 saved")

# ─────────────────────────────────────────────
# CHART 2 — Monthly Revenue Trend
# ─────────────────────────────────────────────
df2 = pd.read_csv('results/monthly_revenue.csv')

# Convert order_month to datetime
df2['order_month'] = pd.to_datetime(df2['order_month'])
df2 = df2.sort_values('order_month')

fig2 = px.line(
    df2,
    x='order_month',
    y='monthly_revenue',
    title='Olist Monthly Revenue Trend (2017–2018)',
    labels={
        'order_month': 'Month',
        'monthly_revenue': 'Revenue (BRL)'
    },
    markers=True
)

fig2.update_traces(
    line_color='#3498db',
    line_width=2.5,
    marker_size=6
)

fig2.update_layout(
    plot_bgcolor='white',
    yaxis_tickformat=',.0f',
    title_font_size=16
)

fig2.write_image('visuals/monthly_revenue.png')
fig2.write_html('visuals/monthly_revenue.html')
print("Chart 2 saved")

# ─────────────────────────────────────────────
# CHART 3 — Freight Cost by Category
# ─────────────────────────────────────────────
df3 = pd.read_csv('results/freight_by_category.csv')

# Sort by freight to price ratio
df3 = df3.sort_values('freight_to_price_ratio_pct', ascending=True)

fig3 = px.bar(
    df3,
    x='freight_to_price_ratio_pct',
    y='product_category_name_english',
    orientation='h',
    title='Freight Cost as % of Product Price by Category (Top 10)',
    labels={
        'freight_to_price_ratio_pct': 'Freight as % of Product Price',
        'product_category_name_english': 'Category'
    },
    text='freight_to_price_ratio_pct',
    color='freight_to_price_ratio_pct',
    color_continuous_scale='Reds'
)

fig3.update_traces(texttemplate='%{text:.1f}%', textposition='outside')
fig3.update_layout(
    plot_bgcolor='white',
    showlegend=False,
    coloraxis_showscale=False,
    title_font_size=16
)

fig3.write_image('visuals/freight_by_category.png')
fig3.write_html('visuals/freight_by_category.html')
print("Chart 3 saved")

print("\nAll 3 charts saved to /visuals folder")