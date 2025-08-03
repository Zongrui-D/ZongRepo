
#DIY- 构造 Milk 数据集 
set.seed(123)


Milk <- data.frame(
  Cow = rep(paste0("Cow", 1:5), each = 10),
  Time = rep(1:10, times = 5),
  protein = round(rnorm(50, mean = 4.5, sd = 0.5), 2),
  Diet = rep(c("barley", "lupins", "barley+lupins", "barley", "lupins"), each = 10)
)

#1.查看数据
summary(Milk)
head(Milk)


#2.开始画图
ggplot(data = Milk, aes(x=Time, y=protein))
#data 数据源，接受dataframe类型
#坐标轴映射Aesthetics（美学） x为Time， y为protein
#此时图的基本框架被建立了，但还没有具体图形元素（比如点、线等），所以图是空的。

#aes具有继承性
#在ggplot()里写的aes()是默认映射
#会被后续图层（如 geom_point()）自动继承。

#3.添加散点
ggplot(data = Milk, aes(x = Time, y = protein)) + 
  geom_point()  # 不需要再次写 aes()
#geom_point()，告诉 ggplot2：在图上画出每一组 (age, weight) 的数据点


#ggplot2 的语法风格就是使用 + 添加图层
#expression (plot + layer + layer + ...)

#4.添加箱线图层
# color=Diet only applies to geom_boxplot
ggplot(data = Milk, aes(x=Time, y=protein)) + 
  geom_point() +
  geom_boxplot(aes(color=Diet))
#添加一个箱线图层，并为这个图层单独指定了颜色映射：color = Diet
#上述代码很烂，只是为了展示语法

#5.一些 aes变量代表的含义
# x=x轴，y=y轴
# color=轮廓线颜色，fill 填充区域颜色
# alpha 透明度 0为完全透明，1为不透明
# linetype 线型（实线，虚线，点线等）
# shape散点图中点的形状
# size对象大小（点的直径，线宽等）

#6. 变量映射 vs 固定设置 写法
# 6.1 这种写法是“把变量映射到颜色”
ggplot(data = Milk, aes(x=Time, y=protein)) + 
  geom_point(aes(color = Diet))
#每个点根据 Diet 的不同显示不同颜色

# 6.2 手动设定常量值 ➜ 放在 aes() 外部
ggplot(data = Milk, aes(x=Time, y=protein)) + 
  geom_point(color = "green")
#所有点都是绿色，与 Diet 无关。这里不是映射，而是直接设定颜色为一个常量。

# 6.3 注意aes里没有具体颜色，只有group
ggplot(data = Milk, aes(x=Time, y=protein)) + 
  geom_point(aes(color="green"))
#类似此中写法会导致R将颜色设置成默认的橙红色

# 7.图层概念
#ggplot2 图是逐层叠加构建的
#ggplot2 不像 Base R 那样“直接生成一个完整图”，它更像是“搭积木”：
#图层包括 geom 或 stat
#geom 图形层：点、线、箱图等
#stat 统计层：平滑拟合、分箱、统计摘要等
#每一层可以继承或重写 aes(),只影响这一层
# 7.1 散点图层（基础图）
ggplot(data = Milk, aes(x = Time, y = protein)) + 
  geom_point()
# 7.2 添加按 Cow 分组的折线图
ggplot(data = Milk, aes(x = Time, y = protein)) + 
  geom_point() + 
  geom_line(aes(group = Cow))
# 7.3添加趋势线图层（平滑估计）
ggplot(data = Milk, aes(x = Time, y = protein)) + 
  geom_point() + 
  geom_line(aes(group = Cow)) + 
  geom_smooth()

#8. 图形可以当作对象来存储与修改
#8.1 图对象可以存入变量
p <- ggplot(data = Milk, aes(x = Time, y = protein)) + 
  geom_point()
#8.2 
#输出变量，才会显示图形
p
#8.3 可以在已有图的基础上添加图层（Layer）
p + geom_boxplot(aes(color = Diet))   # 添加一个箱线图层
#8.4 构建“基础图”作为模板
base_plot <- p
facetted_plot <- base_plot + facet_wrap(. ~ Diet)
#8.5 同时输出多张图
base_plot
facetted_plot
#8.6 使用外部数据添加新图层（非常灵活！）
library(dplyr)
max_protein_by_time <- nlme::Milk %>% group_by(Time) %>% summarise(protein=max(protein))

facetted_plot + geom_smooth()
base_plot + geom_line(data=max_protein_by_time, color="Red")
#8.7添加平滑趋势线（再次巩固）
base_plot + geom_smooth()

#9.核心概念：geom_*() 是绘图中“画什么”的部分
#函数	            说明	            是否需要 x, y
#geom_point()	    散点图	          是
#geom_line()	    折线图	          是
#geom_smooth()	  平滑趋势线	      是（可选）
#geom_histogram()	连续变量直方图	  只需 x
#geom_density()	  连续变量核密度图	只需 x
#geom_bar()	      类别变量的柱状图	默认只需 x
#geom_boxplot()	  箱线图	          是
#geom_errorbar()	误差条	          是
#geom_ribbon()	  区域带图	        是（带上下界）
#9.1 只需要 x 的 geoms
univariate_base <- ggplot(data = Milk, aes(x = protein))
univariate_base 
#9.1.2 Histogram（直方图） 
#显示 protein 的分布（频数），rotein 的分布（频数）
univariate_base + geom_histogram()
#9.1.3 Density plot（核密度图）
#类似直方图但更平滑，展示连续变量的概率密度
univariate_base + geom_density()
#9.1.4 Bar plot（类别变量频数图）
#Diet 是类别变量，柱子高度表示每类的数量（计数）。
ggplot(Milk, aes(x = Diet)) + geom_bar()

#9.2 需要 x 和 y 的 geoms
#创建双变量基础图：
xy_base <- ggplot(data = Milk, aes(x = Time, y = protein))
xy_base
#9.2.1 Scatterplot（散点图）
#显示每一个 Time 与 protein 值的对应点。
xy_base + geom_point()
#9.2.2 Smoothed line（平滑趋势线）
#默认用 loess 平滑，展示随时间变化的趋势。
xy_base + geom_smooth()
#9.2.3 叠加多个 geoms
#点 + 趋势线，常用组合。
xy_base + geom_point() + geom_smooth()
#9.2.4 改变图层顺序
#点后画的内容会覆盖前面的。这里红色点会盖住部分趋势线。
xy_base + geom_smooth() + geom_point(color = "Red")

#10. ggplot2 中的分组绘图方式
#10.1 使用 group = ... 进行显式分组
#geom_line() 默认会将所有数据连成一条线，除非你指定 group。
#📌 示例：每头牛（Cow）一条线，展示随时间变化的 protein 值
xy_base <- ggplot(Milk, aes(x = Time, y = protein))
# 正确：每头牛一条线
xy_base + geom_line(aes(group = Cow))
# 错误：这会连接所有点，画出一条混乱的无意义的线（如图中的“乱麻线”）。
xy_base + geom_line()
#10.2 使用其他 aesthetic（如 color、linetype）隐式分组
#除了显式指定，还可以通过设定其他美学属性
#如 color 来隐式分组，因为 ggplot2 会自动按颜色值对数据分组
#不过如果 Cow 太多，颜色区分效果会很差（视觉负担重）
xy_base + geom_line(aes(color = Cow))
#10.3 组合分组方式：group + color 或 linetype
#10.3.1按 Cow 分组、按 Diet 着色
#更有意义的图层组合：我们知道 Cow 是个体，Diet 是处理变量，
#这样可以帮助你观察不同饮食下的蛋白变化趋势。
xy_base + geom_line(aes(group = Cow, color = Diet))
#10.3.2按 Cow 分组、按 Diet 设置线型
xy_base + geom_line(aes(group = Cow, linetype = Diet))

#11.ggplot2 中的统计图层（Stats）
#11.1 概述
#stat_* 函数对数据进行统计变换（如求均值、置信区间等）。
#每个 stat_* 函数都有默认的 geom 几何对象，也可以通过 geom= 参数改变其表现形式。
#多数情况下可以用 stat_*() 直接绘图而不额外添加 geom_*()。

#11.2 stat_bin()：连续变量分箱，默认画直方图
# 设置基本图层，只指定 x=protein
univariate_base <- ggplot(data = Milk, aes(x = protein))
univariate_base
#11.2.1 默认柱状图效果（等价于 geom_histogram()）
univariate_base + stat_bin()
#11.2.2 用线来画（指定 geom 为 "line"，而不是 geom_line()）
univariate_base + stat_bin(geom = "line")
#11.3 stat_summary()：按组做统计汇总（默认是平均值 ± 标准误）
# 基础图层，x=Time，y=protein
xy_base <- ggplot(data = Milk, aes(x = Time, y = protein))
xy_base
#11.3.1 默认：使用 mean ± SE，图层是点+误差线（等价于 geom_pointrange）
xy_base + stat_summary()
#11.3.2 叠加平滑曲线（顺序影响显示层次）
xy_base + geom_smooth() + stat_summary()
#11.4 使用 stat_summary() 指定其他函数
#11.4.1 内置函数 mean_cl_boot()（平均值+自助法置信区间）
xy_base + stat_summary(fun.data = "mean_cl_boot")
#11.4.2 使用 median()，只返回一个值，因此需设置 geom = "point"
xy_base + stat_summary(fun = "median", geom = "point")
#11.4.3 自定义函数示例（以 log 转换均值为例）
# 自定义函数
meanlog <- function(y) {
  mean(log(y))
}
# 使用自定义函数并改用线图
xy_base + stat_summary(fun = meanlog, geom = "line") +
  ylab("log(protein)")  # 修改 y 轴标签为 log(protein)
#11.5 ggplot2 提供的统计函数
#函数名	          描述	                                  返回值
#mean_cl_boot	    均值和自助法置信区间（默认95%）	        3 个值
#mean_cl_normal	  均值和正态分布估计置信区间	            3 个值
#mean_sdl	        均值 ± k × 标准差（默认 k=2）	          3 个值
#median_hilow	    中位数和上下分位点（默认2.5%、97.5%）	  3 个值

#12 Scales：控制美学属性的映射
#12.1 Scale是什么
#Scales 决定了 数据值如何映射为视觉元素（如颜色、形状、大小等）。
#每种美学属性（aesthetic）都有对应的 scale_*_*() 函数来自定义控制。
#12.2 形状映射：scale_shape_manual()- 将目标换成指定形状
#12.2.1 默认行为：Diet 映射到默认形状
ggplot(Milk, aes(x = Time, y = protein, shape = Diet)) +
  geom_point()
#12.2.2手动设置图形形状（使用代码编号）
ggplot(Milk, aes(x = Time, y = protein, shape = Diet)) +
  geom_point() +
  scale_shape_manual(values = c(5, 3, 8))  # diamond, plus, asterisk
#12.2.3使用自定义字符作为图形（如 B/M/L）
ggplot(Milk, aes(x = Time, y = protein, shape = Diet)) +
  geom_point() +
  scale_shape_manual(values = c("B", "M", "L"))
#12.2.4展示所有图形编号（0~24）
df_shapes <- data.frame(shape = 0:24)
ggplot(df_shapes, aes(0, 0, shape = shape)) +
  geom_point(aes(shape = shape), size = 5, fill = 'red') +
  scale_shape_identity() +
  facet_wrap(. ~ shape) +
  theme_void()
#12.3色彩控制：scale_fill_*() 和 scale_color_*()
#设置密度图基本图层
dDiet <- ggplot(Milk, aes(x = protein, fill = Diet)) +
  geom_density(alpha = 1/3)  # 透明度 alpha=1/3
dDiet
#默认配色（scale_fill_hue()，默认会应用）
dDiet + scale_fill_hue()
#使用 ColorBrewer 提供的色彩方案（适合分组变量）
#定性（qualitative）配色方案
dDiet + scale_fill_brewer(type = "qual")
#发散（diverging）配色方案
dDiet + scale_fill_brewer(type = "div")
#12.4坐标轴范围与标签设置
#使用 lims()、xlim()、ylim() 控制坐标轴范围
ggplot(Milk, aes(x = Time, y = protein)) +
  geom_point() +
  lims(x = c(5, 10), y = c(3, 4)) +
  labs(x = "Weeks", y = "Protein Content")
#其它设置函数
#函数	            功能
#xlab(), ylab()	  设置横纵坐标名称
#ggtitle()	      设置图标题
#labs()	          一次性设置所有标签（推荐）
#xlim(), ylim()	  直接设置范围（与 lims 类似）
#expand_limits()	扩展图形范围

#13. Guides（图例与坐标轴）
#13.1 什么是 Guide？
#Guide（引导） 是 ggplot2 用于展示 scale 的可视化结果的元素，包括：
#Axes（坐标轴）：x、y 等轴线和刻度
#Legends（图例）：颜色、形状、大小等映射的说明
#每个 scale 都有一个对应的 guide（可以是 axis 或 legend）。
#13.2 默认行为：大多数 guides 会自动显示
# 默认图，shape=Diet 会自动显示图例 
# 图例中自动列出了每种 Diet 映射到的图形形状。
ggplot(Milk, aes(x = Time, y = protein, shape = Diet)) +
  geom_point()
#13.3 移除图例的语法：使用 guides() 函数
# 移除 shape 映射的图例，图中不再显示 shape（形状）相关的图例。
ggplot(Milk, aes(x = Time, y = protein, shape = Diet)) +
  geom_point() +
  guides(shape = "none")
#13.4 多个图例控制
#legend：正常显示图例（默认）
#"none"：隐藏图例
#"guide_legend()"：手动调用图例控制器（用于更精细的设置）
ggplot(Milk, aes(x = Time, y = protein, shape = Diet, color = Diet)) +
  geom_point() +
  guides(shape = "none", color = "legend")
#13.5 使用 theme() 函数移除所有图例（快速写法）
ggplot(Milk, aes(x = Time, y = protein, shape = Diet, color = Diet)) +
  geom_point() +
  theme(legend.position = "none")

#14. Facetting（面板分面）——多图排列的神器
#14.1 facet_wrap()
#将一个变量的不同取值“环绕”展开成多个图表
#形式为 facet_wrap(~ variable)，也可以控制行列数，
#如 facet_wrap(~ variable, nrow = 2, ncol = 3)
#. ~ var 表示横向排列；var ~ . 表示纵向排列
# 画出 protein 的密度曲线，按 Diet 着色，并按 Time 分面
# eg.按 Diet 行分面
ggplot(Milk, aes(x = protein, color = Diet)) + 
  geom_density() + 
  facet_wrap(~ Time)
# 每个子图表示一个 Time 的 protein 分布情况

#14.2 facet_grid()
#同时指定行变量和列变量，排列成网格
#语法格式：facet_grid(row_variable ~ column_variable)
#若某方向不分组则用 . 表示
# eg.按 Diet 行分面：
#每一列一个 Diet，小图横向排列
ggplot(Milk, aes(x = Time, y = protein)) + 
  geom_point() + 
  facet_grid(Diet ~ .)
#每一列一个 Diet，小图横向排列

#15. Theme 基础知识
#Theme 控制图形的非数据元素（data-independent elements）
#包括：
#背景颜色、边框线、图例位置
#坐标轴线、标题、标签文字
#网格线样式
#字体、颜色、大小
#15.1 常见的Theme 元素分类及设置方法
#类型	      控制元素	                            设置函数	      示例功能
#文本元素	  axis.title, plot.title等	            element_text()	控制字体大小、颜色、对齐等
#线条元素	  axis.line, panel.grid	                element_line()	控制线条颜色、粗细、类型
#矩形元素	  panel.background, legend.background	  element_rect()	控制背景颜色、边框颜色等
#删除元素	  任意 theme 元素	                      element_blank()	从图中删除该元素

#这些元素都不改变图表所表达的数据，只影响美观性和可读性。

#15.2 基本使用方法：theme()
#15.2.1 更改背景颜色
ggplot(Milk, aes(x = Time, y = protein)) +
  geom_point() +
  theme(panel.background = element_rect(fill = "lightblue"))
#15.2.2 修改 x 轴标题字体大小和颜色
ggplot(Milk, aes(x = Time, y = protein)) +
  geom_point() +
  theme(axis.title.x = element_text(size = 20, color = "red"))
#15.2.3 删除 y 轴标题
ggplot(Milk, aes(x = Time, y = protein)) +
  geom_point() +
  theme(axis.title.y = element_blank())

#15.3 常用 Theme 元素速查表
#元素名称	            描述
#panel.background	    图表背景（绘图区域）
#plot.background	    整个图形背景
#panel.grid.major	    主网格线
#panel.grid.minor	    次网格线
#axis.title.x/y	      x / y 轴标题
#axis.text.x/y	      x / y 轴刻度文字
#legend.position	    图例位置（"left", "right", "none"）
#plot.title	          主标题样式

#15.4  示例：整合多个主题修改
ggplot(Milk, aes(x = Time, y = protein, color = Diet)) +
  geom_point() +
  labs(title = "Protein Over Time", x = "Day", y = "Protein Level") +
  theme(
    panel.background = element_rect(fill = "ivory"),
    axis.title.x = element_text(size = 16, color = "blue"),
    axis.title.y = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    legend.position = "bottom"
  )

#15.5附加：快速使用内建主题
#ggplot2 提供一些内建主题风格（不需一个个手动改）：

#函数	              风格说明
#theme_gray()	      默认主题（灰色背景）
#theme_bw()	        黑白背景，适合出版
#theme_minimal()	  极简风格，去除很多辅助线
#theme_classic()	  类似基础图形系统样式
#theme_void()	      清空所有背景、坐标轴，非常干净

#16.保存图像 ggsave() 函数
ggsave("filename.png", plot = p, width = 7, height = 5, units = "cm")
#参数	              说明
#"filename.png"	    指定文件保存路径和格式（扩展名决定格式）
#plot = p	          要保存的图像对象，如果不写，则默认保存上一个显示的图
#width, height	    图像的宽度和高度（使用 units 指定单位）
#units	            "in"（英寸）、"cm"（厘米）、"mm"（毫米）#
#e.g.
# 创建图像对象 p
p <- ggplot(Milk, aes(x = Time, y = protein)) + 
  geom_point()
p
# 保存图像到本地（注意修改路径）
ggsave("~/Desktop/myplot.png", plot = p, width = 7, height = 5, units = "cm")
1#"~/Desktop/myplot.png" → 保存到桌面（macOS/Linux）
#"C:/Users/你的用户名/Desktop/myplot.png" → Windows 用户桌面
#"myplot.pdf" → 保存为 PDF 格式


#test commit