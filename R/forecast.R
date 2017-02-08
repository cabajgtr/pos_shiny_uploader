source("R/import_tools.R")
db <- db_connect()
forecast_dump <- getForecastData()

fcb <- forecast_dump %>% 
  filter(yearmonth >= '201701', yearmonth <= '201703') %>% 
  group_by(account_manager, nature) %>% 
  summarize(value = sum(ship_sales)) %>% collect() %>% 
  spread(nature, value, fill = 0) %>% 
  summarize(shipments = sum(Invoice), forecast = sum(forecast),rname = 'bookings', rmin = 0, rbookings = sum(Invoice) + sum(Sales_Order) + sum(Credit_Note), rcolor = '#b0b0b0') %>% 
  mutate(scalemax = max(shipments, forecast, rbookings))

n <- 1

amBulletDF <- function(df) {
amBullet(value = df$shipments,
         limit = df$forecast,
         limit_color = '#00ff00',
         min = 0,
         max = df$scalemax * 1.2,
         rate = data.frame(name = df$rname, min = df$rmin, max = df$rbookings, color = df$rcolor)
         )
}

fcBulletCharts <- fcb %>% split(.$account_manager) %>% 
        map(amBulletDF) %>% 
        map(renderAmCharts)
        

p <- figure() %>% 
  ly_point(x= account_manager, y = ship_units, data = forecast_dump, hover = list(ship_units, ship_sales))ly_points()
  
require("d3Dashboard")

ytd2005 <- list(  
  title=list("Revenue"),
  subtitle=list("US$, in thousands"),
  range=list(0),
  measures=list(c(220, 270)),
  markers=list(250)
)

# Plot
bulletGraph(ytd2005)  

data('data_stock1')

  amStockChart(startDuration = 0) %>% 
  setExport() %>% 
  addDataSet(
      dataSet(title = 'first data set', categoryField = 'date',
              dataProvider = stockdata) %>% 
      addFieldMapping(fromField = 'value', toField = 'value') %>% 
      addFieldMapping(fromField = 'volume', toField = 'volume')
  ) %>% 
  addPanel(
      stockPanel(showCategoryAxis = FALSE, title = 'Value', percentHeight = 70) %>% 
      addStockGraph(id = 'g1', valueField = 'value', comparable = TRUE,
                    compareField = 'value', balloonText = '[[title]] =<b>[[value]]</b>',
                    compareGraphBalloonText = '[[title]] =<b>[[value]]</b>') %>% 
      setStockLegend(periodValueTextComparing = '[[percents.value.close]]%',
                     periodValueTextRegular = '[[value.close]]')) %>% 
  addPanel(
      stockPanel(title = 'Volume', percentHeight = 30) %>% 
                    addStockGraph(valueField = 'volume', type = 'column', fillAlphas = 1) %>% 
                    setStockLegend(periodValueTextRegular = '[[value.close]]')) %>% 
  setChartScrollbarSettings(graph = 'g1')
#  setChartCursorSettings(valueBalloonsEnabled = TRUE, fullWidth = TRUE,
#                         cursorAlpha = 0.1, valueLineBalloonEnabled = TRUE,
#                         valueLineEnabled = TRUE, valueLineAlpha = 0.5),
  #setPeriodSelector(
  #  pipeR::pipeline(periodSelector(position = 'left'),
  #                  addPeriod(period = 'DD', selected = TRUE, count = 7, label = '1 week'),
  #                  addPeriod(period = 'MAX', label = 'MAX'))
  #),
#  setDataSetSelector(position = 'left'),
#  setPanelsSettings(recalculateToPercents = FALSE)
#)
  
  dat <- read.csv('http://t.co/mN2RgcyQFc')[,c('date', 'pts')]
  library(rChartsCalmap)
  r1 <- calheatmap(x = 'date', y = 'pts',
                   data = dat, 
                   domain = 'month',
                   start = "2012-10-27",
                   legend = seq(10, 50, 10),
                   itemName = 'point',
                   range = 7
  )
  r1
