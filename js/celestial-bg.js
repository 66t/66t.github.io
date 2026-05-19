document.addEventListener('DOMContentLoaded', () => {
    const canvas = document.getElementById('skyCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    // 监听窗口大小变化以重置画布
    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight-6;
    }
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();

    //=============================================================================
    // 核心物理与天文逻辑 (从 RPG Maker 插件移植)
    //=============================================================================
    const CelestialManager = {
        G: 39.478,
        _minutesPerSecond: 60,
        observerConfig: { body: "地球", lat: 31.2, lon: 121.4 },
        bodies: [],
        
        CONSTELLATIONS :  [
            {
                name: "大熊座",
                center: { ra: 165.0, dec: 55.0 },
                color: "rgba(200, 220, 255, 0.5)",
                lines: [
                    // 北斗七星：天枢、天璇、天玑、天权、玉衡、开阳、瑶光
                    [
                        {ra: 165.9, dec: 61.7, mag: 1.8}, {ra: 164.4, dec: 56.3, mag: 2.3},
                        {ra: 178.4, dec: 53.6, mag: 2.4}, {ra: 183.8, dec: 57.0, mag: 3.3},
                        {ra: 193.5, dec: 55.9, mag: 1.8}, {ra: 200.9, dec: 54.9, mag: 2.2},
                        {ra: 206.8, dec: 49.3, mag: 1.8}
                    ],
                    // 勺口闭合
                    [{ra: 165.9, dec: 61.7, mag: 1.8}, {ra: 183.8, dec: 57.0, mag: 3.3}]
                ]
            },
            {
                name: "猎户座",
                center: { ra: 83.0, dec: 0.0 },
                color: "rgba(255, 200, 200, 0.6)",
                lines: [
                    // 腰带：参宿一、参宿二、参宿三
                    [{ra: 83.0, dec: -0.3, mag: 2.2}, {ra: 84.0, dec: -1.2, mag: 1.7}, {ra: 85.1, dec: -1.9, mag: 2.2}],
                    // 身体轮廓：参宿四(左上)、参宿五(右上)、参宿六(左下)、参宿七(右下)
                    [{ra: 88.7, dec: 7.4, mag: 0.4}, {ra: 81.2, dec: 6.3, mag: 1.6}],
                    [{ra: 88.7, dec: 7.4, mag: 0.4}, {ra: 86.9, dec: -9.6, mag: 2.0}],
                    [{ra: 81.2, dec: 6.3, mag: 1.6}, {ra: 78.6, dec: -8.2, mag: 0.1}],
                    [{ra: 86.9, dec: -9.6, mag: 2.0}, {ra: 78.6, dec: -8.2, mag: 0.1}]
                ]
            },
            {
                name: "仙后座",
                center: { ra: 15.0, dec: 60.0 },
                color: "rgba(200, 255, 200, 0.5)",
                lines: [
                    // W形状：王良四、策、阁道三、阁道二、阁道一
                    [{ra: 1.4, dec: 59.1, mag: 2.2}, {ra: 9.1, dec: 56.5, mag: 2.4}, {ra: 14.3, dec: 60.7, mag: 2.1}, {ra: 21.0, dec: 60.2, mag: 2.7}, {ra: 28.5, dec: 63.6, mag: 3.4}]
                ]
            },
            {
                name: "大犬座",
                center: { ra: 101.0, dec: -20.0 },
                color: "rgba(150, 200, 255, 0.6)",
                lines: [
                    // 天狼星及主干
                    [{ra: 101.3, dec: -16.7, mag: -1.46}, {ra: 105.0, dec: -26.4, mag: 2.0}, {ra: 102.4, dec: -30.0, mag: 2.4}],
                    [{ra: 101.3, dec: -16.7, mag: -1.46}, {ra: 95.0, dec: -18.0, mag: 2.0}],
                    [{ra: 105.0, dec: -26.4, mag: 2.0}, {ra: 110.0, dec: -29.0, mag: 1.5}]
                ]
            },
            {
                name: "天琴座",
                center: { ra: 283.0, dec: 38.0 },
                color: "rgba(200, 220, 255, 0.6)",
                lines: [
                    // 织女一及平行四边形
                    [{ra: 279.2, dec: 38.8, mag: 0.0}, {ra: 282.4, dec: 33.3, mag: 3.2}, {ra: 284.2, dec: 36.9, mag: 3.4}],
                    [{ra: 284.2, dec: 36.9, mag: 3.4}, {ra: 287.8, dec: 32.7, mag: 3.5}, {ra: 282.4, dec: 33.3, mag: 3.2}]
                ]
            },
            {
                name: "天鹰座",
                center: { ra: 295.0, dec: 8.0 },
                color: "rgba(255, 255, 200, 0.5)",
                lines: [
                    // 牛郎星及两翼
                    [{ra: 293.4, dec: 10.6, mag: 3.7}, {ra: 297.7, dec: 8.9, mag: 0.77}, {ra: 300.0, dec: 6.4, mag: 2.7}],
                    [{ra: 297.7, dec: 8.9, mag: 0.77}, {ra: 286.0, dec: 1.0, mag: 3.0}]
                ]
            },
            {
                name: "天鹅座",
                center: { ra: 305.0, dec: 40.0 },
                color: "rgba(255, 255, 255, 0.5)",
                lines: [
                    // 天津四及北十字
                    [{ra: 310.3, dec: 45.2, mag: 1.25}, {ra: 305.5, dec: 40.2, mag: 2.2}, {ra: 292.6, dec: 27.9, mag: 3.0}],
                    [{ra: 296.2, dec: 45.1, mag: 3.7}, {ra: 305.5, dec: 40.2, mag: 2.2}, {ra: 313.3, dec: 33.9, mag: 2.5}]
                ]
            },
            {
                name: "狮子座",
                center: { ra: 160.0, dec: 15.0 },
                color: "rgba(255, 220, 150, 0.5)",
                lines: [
                    // 轩辕十四(镰刀形)与尾巴
                    [{ra: 152.0, dec: 11.9, mag: 1.3}, {ra: 154.9, dec: 19.8, mag: 3.4}, {ra: 154.1, dec: 23.4, mag: 2.2}],
                    [{ra: 152.0, dec: 11.9, mag: 1.3}, {ra: 168.5, dec: 20.5, mag: 2.5}, {ra: 177.2, dec: 14.5, mag: 2.1}]
                ]
            },
            {
                name: "天蝎座",
                center: { ra: 250.0, dec: -30.0 },
                color: "rgba(255, 180, 150, 0.6)",
                lines: [
                    // 心宿二及钩状尾巴
                    [{ra: 241.1, dec: -19.8, mag: 2.3}, {ra: 246.3, dec: -25.5, mag: 2.9}, {ra: 247.3, dec: -26.4, mag: 1.0}, {ra: 252.7, dec: -34.2, mag: 2.8}, {ra: 257.9, dec: -39.0, mag: 2.4}, {ra: 263.2, dec: -43.0, mag: 1.6}]
                ]
            },
            {
                name: "南十字座",
                center: { ra: 186.0, dec: -60.0 },
                color: "rgba(180, 220, 255, 0.6)",
                lines: [
                    // 十字架结构
                    [{ra: 187.7, dec: -59.6, mag: 0.7}, {ra: 186.6, dec: -63.1, mag: 0.8}],
                    [{ra: 191.9, dec: -59.6, mag: 1.2}, {ra: 181.3, dec: -57.1, mag: 1.6}]
                ]
            },
            {
                name: "金牛座",
                center: { ra: 65.0, dec: 19.0 },
                color: "rgba(255, 160, 122, 0.5)",
                lines: [
                    // 毕宿五及V形头部（毕星团）
                    [{ra: 68.9, dec: 16.5, mag: 0.87}, {ra: 65.1, dec: 15.8, mag: 3.5}, {ra: 64.0, dec: 17.5, mag: 3.8}, {ra: 66.8, dec: 19.2, mag: 3.4}],
                    // 牛角延伸
                    [{ra: 68.9, dec: 16.5, mag: 0.87}, {ra: 84.4, dec: 28.6, mag: 1.6}], // 到五车五
                    [{ra: 66.8, dec: 19.2, mag: 3.4}, {ra: 81.3, dec: 21.1, mag: 3.0}]
                ]
            },
            {
                name: "双子座",
                center: { ra: 105.0, dec: 22.0 },
                color: "rgba(175, 238, 238, 0.5)",
                lines: [
                    // 北河三(Pollux)及其躯干
                    [{ra: 116.3, dec: 28.0, mag: 1.1}, {ra: 110.1, dec: 24.4, mag: 3.5}, {ra: 100.5, dec: 16.5, mag: 3.3}],
                    // 北河二(Castor)及其躯干
                    [{ra: 113.6, dec: 31.9, mag: 1.6}, {ra: 107.0, dec: 25.1, mag: 2.9}, {ra: 96.0, dec: 22.5, mag: 3.3}],
                    // 两者肩部连线
                    [{ra: 110.1, dec: 24.4, mag: 3.5}, {ra: 107.0, dec: 25.1, mag: 2.9}]
                ]
            },
            {
                name: "牧夫座",
                center: { ra: 215.0, dec: 30.0 },
                color: "rgba(255, 250, 205, 0.5)",
                lines: [
                    // 大角星(Arcturus)及其风筝轮廓
                    [{ra: 213.9, dec: 19.2, mag: -0.05}, {ra: 210.4, dec: 28.4, mag: 2.7}, {ra: 217.4, dec: 33.3, mag: 2.4}],
                    [{ra: 217.4, dec: 33.3, mag: 2.4}, {ra: 225.5, dec: 40.3, mag: 2.7}, {ra: 220.5, dec: 48.3, mag: 3.0}, {ra: 210.4, dec: 28.4, mag: 2.7}]
                ]
            },
            {
                name: "仙女座",
                center: { ra: 15.0, dec: 40.0 },
                color: "rgba(230, 230, 250, 0.5)",
                lines: [
                    // 壁宿二连向英仙座
                    [{ra: 2.1, dec: 29.1, mag: 2.1}, {ra: 17.4, dec: 35.6, mag: 2.1}, {ra: 30.2, dec: 42.3, mag: 2.1}]
                ]
            },
            {
                name: "飞马座",
                center: { ra: 345.0, dec: 20.0 },
                color: "rgba(255, 255, 255, 0.4)",
                lines: [
                    // 飞马座大四方形（壁宿二借用自仙女座）
                    [{ra: 345.9, dec: 15.2, mag: 2.5}, {ra: 346.2, dec: 28.1, mag: 2.4}, {ra: 2.1, dec: 29.1, mag: 2.1}, {ra: 3.5, dec: 15.2, mag: 2.8}, {ra: 345.9, dec: 15.2, mag: 2.5}]
                ]
            },
            {
                name: "室女座",
                center: { ra: 200.0, dec: 0.0 },
                color: "rgba(255, 240, 245, 0.5)",
                lines: [
                    // 角宿一(Spica)及其Y字型
                    [{ra: 201.3, dec: -11.2, mag: 1.0}, {ra: 199.1, dec: -1.4, mag: 3.4}, {ra: 191.0, dec: 1.8, mag: 2.8}],
                    [{ra: 199.1, dec: -1.4, mag: 3.4}, {ra: 204.1, dec: 11.0, mag: 2.9}]
                ]
            },
            {
                name: "英仙座",
                center: { ra: 50.0, dec: 45.0 },
                color: "rgba(240, 255, 240, 0.5)",
                lines: [
                    // 大陵五及主干（人字形）
                    [{ra: 45.5, dec: 41.0, mag: 2.1}, {ra: 51.1, dec: 49.9, mag: 1.8}, {ra: 57.0, dec: 55.9, mag: 3.0}],
                    [{ra: 51.1, dec: 49.9, mag: 1.8}, {ra: 38.0, dec: 48.5, mag: 3.0}]
                ]
            },
            {
                name: "人马座",
                center: { ra: 285.0, dec: -25.0 },
                color: "rgba(255, 228, 225, 0.5)",
                lines: [
                    // 茶壶形状
                    [{ra: 280.0, dec: -25.4, mag: 2.7}, {ra: 282.8, dec: -21.1, mag: 2.8}, {ra: 271.1, dec: -29.9, mag: 1.8}, {ra: 280.0, dec: -25.4, mag: 2.7}],
                    [{ra: 280.0, dec: -25.4, mag: 2.7}, {ra: 287.0, dec: -26.3, mag: 2.0}, {ra: 286.0, dec: -34.4, mag: 2.1}, {ra: 278.0, dec: -36.8, mag: 2.6}, {ra: 271.1, dec: -29.9, mag: 1.8}]
                ]
            },
            {
                name: "小熊座",
                center: { ra: 250.0, dec: 75.0 },
                color: "rgba(255, 255, 200, 0.5)",
                lines: [
                    // 北极星及小北斗
                    [{ra: 37.9, dec: 89.3, mag: 2.0}, {ra: 27.0, dec: 71.8, mag: 4.3}, {ra: 236.4, dec: 74.2, mag: 2.1}, {ra: 230.1, dec: 77.8, mag: 3.0}, {ra: 27.0, dec: 71.8, mag: 4.3}]
                ]
            },
            {
                name: "蛇夫座",
                center: { ra: 255.0, dec: 0.0 },
                color: "rgba(245, 245, 220, 0.5)",
                lines: [
                    // 巨大的多边形结构
                    [{ra: 263.7, dec: 12.6, mag: 2.1}, {ra: 256.0, dec: 9.4, mag: 2.7}, {ra: 242.0, dec: -3.7, mag: 2.6}, {ra: 257.0, dec: -15.6, mag: 2.4}, {ra: 265.0, dec: -9.8, mag: 2.6}, {ra: 263.7, dec: 12.6, mag: 2.1}]
                ]
            },
            {
                name: "天秤座",
                center: { ra: 225.0, dec: -15.0 },
                color: "rgba(210, 180, 140, 0.5)",
                lines: [
                    // 秤杆与秤盘：氐宿四、氐宿一、氐宿三、折威七
                    [{ra: 223.1, dec: -9.4, mag: 2.6}, {ra: 222.7, dec: -16.0, mag: 2.7}, {ra: 233.0, dec: -25.3, mag: 3.3}],
                    [{ra: 223.1, dec: -9.4, mag: 2.6}, {ra: 232.0, dec: -14.8, mag: 3.9}, {ra: 233.0, dec: -25.3, mag: 3.3}]
                ]
            },
            {
                name: "武仙座",
                center: { ra: 255.0, dec: 30.0 },
                color: "rgba(176, 196, 222, 0.5)",
                lines: [
                    // 核心“蝴蝶”或“拱顶石”形状
                    [{ra: 243.6, dec: 31.6, mag: 3.5}, {ra: 248.1, dec: 21.5, mag: 3.1}, {ra: 258.1, dec: 24.8, mag: 3.2}, {ra: 254.0, dec: 36.8, mag: 2.8}, {ra: 243.6, dec: 31.6, mag: 3.5}],
                    // 伸出的肢体
                    [{ra: 248.1, dec: 21.5, mag: 3.1}, {ra: 257.0, dec: 14.4, mag: 3.0}],
                    [{ra: 254.0, dec: 36.8, mag: 2.8}, {ra: 241.0, dec: 48.0, mag: 3.4}]
                ]
            },
            {
                name: "北冕座",
                center: { ra: 233.0, dec: 27.0 },
                color: "rgba(255, 215, 0, 0.4)",
                lines: [
                    // 完美的半圆形贯索
                    [{ra: 230.1, dec: 29.1, mag: 4.1}, {ra: 231.5, dec: 30.3, mag: 3.6}, {ra: 233.7, dec: 26.7, mag: 2.2}, {ra: 236.4, dec: 25.6, mag: 3.8}, {ra: 239.5, dec: 26.3, mag: 4.1}]
                ]
            },
            {
                name: "海豚座",
                center: { ra: 308.0, dec: 13.0 },
                color: "rgba(135, 206, 250, 0.6)",
                lines: [
                    // 菱形头部（约伯的棺材）与尾巴
                    [{ra: 309.8, dec: 15.9, mag: 3.8}, {ra: 307.5, dec: 15.1, mag: 3.8}, {ra: 308.4, dec: 11.1, mag: 4.0}, {ra: 310.9, dec: 13.2, mag: 4.1}, {ra: 309.8, dec: 15.9, mag: 3.8}],
                    [{ra: 308.4, dec: 11.1, mag: 4.0}, {ra: 314.1, dec: 6.1, mag: 4.4}]
                ]
            },
            {
                name: "御夫座",
                center: { ra: 85.0, dec: 42.0 },
                color: "rgba(255, 245, 238, 0.5)",
                lines: [
                    // 以五车二为首的大五边形
                    [{ra: 79.2, dec: 46.0, mag: 0.08}, {ra: 74.8, dec: 41.1, mag: 2.7}, {ra: 75.0, dec: 30.1, mag: 3.3}, {ra: 84.4, dec: 28.6, mag: 1.6}, {ra: 90.0, dec: 33.3, mag: 2.6}, {ra: 79.2, dec: 46.0, mag: 0.08}]
                ]
            },
            {
                name: "巨蟹座",
                center: { ra: 130.0, dec: 20.0 },
                color: "rgba(192, 192, 192, 0.4)",
                lines: [
                    // 倒Y字形
                    [{ra: 133.1, dec: 18.1, mag: 3.9}, {ra: 127.3, dec: 11.9, mag: 3.5}],
                    [{ra: 133.1, dec: 18.1, mag: 3.9}, {ra: 124.5, dec: 26.5, mag: 4.1}],
                    [{ra: 133.1, dec: 18.1, mag: 3.9}, {ra: 137.9, dec: 17.7, mag: 4.2}]
                ]
            },
            {
                name: "摩羯座",
                center: { ra: 315.0, dec: -20.0 },
                color: "rgba(222, 184, 135, 0.5)",
                lines: [
                    // 大三角/帆船形状
                    [{ra: 304.3, dec: -12.5, mag: 3.6}, {ra: 314.3, dec: -14.8, mag: 3.1}, {ra: 326.2, dec: -16.1, mag: 2.8}, {ra: 324.7, dec: -22.4, mag: 3.3}, {ra: 310.2, dec: -26.3, mag: 3.7}, {ra: 304.3, dec: -12.5, mag: 3.6}]
                ]
            },
            {
                name: "天兔座",
                center: { ra: 83.0, dec: -20.0 },
                color: "rgba(240, 248, 255, 0.5)",
                lines: [
                    // 位于猎户座下方的小四方形
                    [{ra: 82.2, dec: -17.8, mag: 2.6}, {ra: 83.8, dec: -20.8, mag: 2.8}, {ra: 88.3, dec: -20.8, mag: 3.2}, {ra: 86.2, dec: -14.8, mag: 3.3}, {ra: 82.2, dec: -17.8, mag: 2.6}]
                ]
            },
            {
                name: "长蛇座",
                center: { ra: 165.0, dec: -20.0 },
                color: "rgba(144, 238, 144, 0.4)",
                lines: [
                    // 极其漫长的蛇形（仅取头部和主折线）
                    [{ra: 127.3, dec: 6.8, mag: 3.4}, {ra: 129.5, dec: 9.3, mag: 3.1}, {ra: 132.8, dec: 6.4, mag: 3.7}, {ra: 142.1, dec: -8.7, mag: 1.9}, {ra: 162.2, dec: -16.2, mag: 2.8}, {ra: 182.4, dec: -23.2, mag: 3.0}, {ra: 210.8, dec: -28.1, mag: 3.1}]
                ]
            },
            {
                name: "白羊座",
                center: { ra: 35.0, dec: 20.0 },
                color: "rgba(255, 192, 203, 0.5)",
                lines: [
                    // 简单的三点折线（羊角）
                    [{ra: 31.6, dec: 23.5, mag: 2.0}, {ra: 28.5, dec: 20.8, mag: 2.6}, {ra: 27.2, dec: 19.3, mag: 3.9}]
                ]
            },
            {
                name: "波江座",
                center: { ra: 50.0, dec: -20.0 },
                color: "rgba(100, 149, 237, 0.4)",
                lines: [
                    // 从猎户座脚下的水委三开始的一条长弧线
                    [{ra: 76.5, dec: -5.1, mag: 2.8}, {ra: 63.3, dec: -9.8, mag: 3.7}, {ra: 54.0, dec: -10.3, mag: 3.5}, {ra: 48.0, dec: -24.7, mag: 3.2}, {ra: 24.4, dec: -57.2, mag: 0.45}]
                ]
            },
            {
                name: "鲸鱼座",
                center: { ra: 30.0, dec: -10.0 },
                color: "rgba(112, 128, 144, 0.5)",
                lines: [
                    // 头部（五边形）
                    [{ra: 45.5, dec: 3.2, mag: 2.5}, {ra: 40.5, dec: -10.0, mag: 3.6}, {ra: 33.0, dec: -12.1, mag: 2.0}, {ra: 18.0, dec: -18.0, mag: 2.0}, {ra: 10.5, dec: -10.2, mag: 3.5}, {ra: 45.5, dec: 3.2, mag: 2.5}]
                ]
            },
            {
                name: "半人马座",
                center: { ra: 200.0, dec: -50.0 },
                color: "rgba(255, 218, 185, 0.6)",
                lines: [
                    // 包含著名的南门二和马腹一
                    [{ra: 219.9, dec: -60.8, mag: -0.01}, {ra: 210.7, dec: -60.4, mag: 0.6}, {ra: 203.4, dec: -47.3, mag: 2.3}, {ra: 181.5, dec: -36.4, mag: 2.1}]
                ]
            },
            {
                name: "宝瓶座",
                center: { ra: 340.0, dec: -10.0 },
                color: "rgba(173, 216, 230, 0.4)",
                lines: [
                    // “水瓶”倾倒的流向线
                    [{ra: 331.0, dec: -0.3, mag: 2.9}, {ra: 332.3, dec: -5.6, mag: 2.9}, {ra: 338.5, dec: -7.5, mag: 3.3}, {ra: 347.0, dec: -15.8, mag: 3.3}]
                ]
            },
            {
                name: "双鱼座",
                center: { ra: 15.0, dec: 15.0 },
                color: "rgba(240, 255, 255, 0.4)",
                lines: [
                    // 两条鱼的连接点（V形）
                    [{ra: 23.0, dec: 3.2, mag: 3.8}, {ra: 2.0, dec: 6.0, mag: 4.0}],
                    [{ra: 23.0, dec: 3.2, mag: 3.8}, {ra: 22.0, dec: 30.0, mag: 3.6}]
                ]
            },
            {
                name: "船底座",
                center: { ra: 135.0, dec: -60.0 },
                color: "rgba(255, 250, 240, 0.6)",
                lines: [
                    // 老人星(Canopus)及船体
                    [{ra: 95.8, dec: -52.7, mag: -0.74}, {ra: 137.9, dec: -59.3, mag: 1.8}, {ra: 157.0, dec: -59.0, mag: 2.2}]
                ]
            },
            {
                name: "船帆座",
                center: { ra: 140.0, dec: -50.0 },
                color: "rgba(176, 224, 230, 0.4)",
                lines: [
                    // 包含“伪十字”的一部分
                    [{ra: 130.2, dec: -43.4, mag: 2.2}, {ra: 141.6, dec: -47.2, mag: 1.7}, {ra: 128.5, dec: -47.2, mag: 2.0}, {ra: 130.2, dec: -43.4, mag: 2.2}]
                ]
            },
            {
                name: "天鹤座",
                center: { ra: 340.0, dec: -45.0 },
                color: "rgba(224, 255, 255, 0.5)",
                lines: [
                    // 笔直的“鹤”身
                    [{ra: 332.1, dec: -47.0, mag: 1.7}, {ra: 340.0, dec: -43.0, mag: 2.1}, {ra: 348.0, dec: -46.0, mag: 3.0}]
                ]
            },
            {
                name: "凤凰座",
                center: { ra: 10.0, dec: -45.0 },
                color: "rgba(255, 127, 80, 0.5)",
                lines: [
                    // 火鸟的主干
                    [{ra: 6.4, dec: -42.3, mag: 2.4}, {ra: 20.0, dec: -46.0, mag: 3.3}, {ra: 23.5, dec: -43.0, mag: 3.4}]
                ]
            },
            {
                name: "天坛座",
                center: { ra: 250.0, dec: -55.0 },
                color: "rgba(255, 222, 173, 0.4)",
                lines: [
                    // 银河背景下的祭坛
                    [{ra: 260.0, dec: -49.0, mag: 2.8}, {ra: 254.0, dec: -56.0, mag: 2.8}, {ra: 262.0, dec: -60.0, mag: 3.1}]
                ]
            },
            {
                name: "乌鸦座",
                center: { ra: 185.0, dec: -18.0 },
                color: "rgba(169, 169, 169, 0.6)",
                lines: [
                    // 紧凑的四边形，春季大三角下方的显著标志
                    [{ra: 182.4, dec: -16.2, mag: 2.6}, {ra: 187.4, dec: -16.5, mag: 3.0}, {ra: 190.1, dec: -23.4, mag: 2.6}, {ra: 183.1, dec: -22.6, mag: 3.0}, {ra: 182.4, dec: -16.2, mag: 2.6}]
                ]
            },
            {
                name: "巨爵座",
                center: { ra: 170.0, dec: -15.0 },
                color: "rgba(255, 250, 205, 0.4)",
                lines: [
                    // 碗状结构，紧邻乌鸦座
                    [{ra: 164.0, dec: -18.0, mag: 4.0}, {ra: 173.0, dec: -14.0, mag: 3.5}, {ra: 178.0, dec: -17.0, mag: 3.8}],
                    [{ra: 173.0, dec: -14.0, mag: 3.5}, {ra: 175.0, dec: -20.0, mag: 4.1}]
                ]
            },
            {
                name: "天龙座",
                center: { ra: 260.0, dec: 65.0 },
                color: "rgba(143, 188, 143, 0.4)",
                lines: [
                    // 盘绕在大、小熊座之间的长蛇状
                    [{ra: 268.0, dec: 52.0, mag: 2.7}, {ra: 257.0, dec: 56.0, mag: 3.3}, {ra: 247.0, dec: 58.0, mag: 3.0}, {ra: 220.0, dec: 65.0, mag: 3.7}, {ra: 200.0, dec: 70.0, mag: 3.3}, {ra: 170.0, dec: 75.0, mag: 4.0}]
                ]
            },
            {
                name: "仙王座",
                center: { ra: 335.0, dec: 70.0 },
                color: "rgba(255, 240, 245, 0.4)",
                lines: [
                    // 像一个小房子或信封
                    [{ra: 320.0, dec: 62.0, mag: 3.2}, {ra: 332.0, dec: 70.0, mag: 3.4}, {ra: 350.0, dec: 77.0, mag: 2.4}, {ra: 31.0, dec: 79.0, mag: 3.5}, {ra: 320.0, dec: 62.0, mag: 3.2}],
                    [{ra: 332.0, dec: 70.0, mag: 3.4}, {ra: 10.0, dec: 85.0, mag: 4.2}]
                ]
            },
            {
                name: "猎犬座",
                center: { ra: 195.0, dec: 40.0 },
                color: "rgba(245, 245, 245, 0.5)",
                lines: [
                    // 简单的两点连线：常陈一和常陈二
                    [{ra: 193.0, dec: 38.3, mag: 2.9}, {ra: 187.0, dec: 41.3, mag: 4.2}]
                ]
            },
            {
                name: "后发座",
                center: { ra: 192.0, dec: 23.0 },
                color: "rgba(255, 255, 224, 0.3)",
                lines: [
                    // L型直角折线
                    [{ra: 197.0, dec: 17.5, mag: 4.3}, {ra: 190.0, dec: 23.0, mag: 4.4}, {ra: 183.0, dec: 26.0, mag: 4.5}]
                ]
            },
            {
                name: "盾牌座",
                center: { ra: 277.0, dec: -10.0 },
                color: "rgba(211, 211, 211, 0.4)",
                lines: [
                    // 银河中最亮区域的小菱形
                    [{ra: 276.0, dec: -5.0, mag: 3.8}, {ra: 279.0, dec: -8.0, mag: 4.2}, {ra: 282.0, dec: -14.0, mag: 4.5}]
                ]
            },
            {
                name: "海豚座",
                center: { ra: 308.0, dec: 13.0 },
                color: "rgba(173, 216, 230, 0.6)",
                lines: [
                    // 小而精致的菱形（头部）加尾巴
                    [{ra: 309.8, dec: 15.9, mag: 3.8}, {ra: 307.5, dec: 15.1, mag: 3.8}, {ra: 308.4, dec: 11.1, mag: 4.0}, {ra: 310.9, dec: 13.2, mag: 4.1}, {ra: 309.8, dec: 15.9, mag: 3.8}],
                    [{ra: 308.4, dec: 11.1, mag: 4.0}, {ra: 314.1, dec: 6.1, mag: 4.4}]
                ]
            },
            {
                name: "鹿豹座",
                center: { ra: 85.0, dec: 70.0 },
                color: "rgba(240, 240, 240, 0.2)",
                lines: [
                    // 极淡的长线，位于大熊座和御夫座之间
                    [{ra: 55.0, dec: 66.0, mag: 4.0}, {ra: 75.0, dec: 60.0, mag: 4.6}, {ra: 100.0, dec: 60.0, mag: 4.4}]
                ]
            },
            {
                name: "天兔座",
                center: { ra: 83.0, dec: -20.0 },
                color: "rgba(220, 220, 220, 0.5)",
                lines: [
                    // 猎户座脚下的“兔子”
                    [{ra: 82.2, dec: -17.8, mag: 2.6}, {ra: 83.8, dec: -20.8, mag: 2.8}, {ra: 88.3, dec: -20.8, mag: 3.2}, {ra: 86.2, dec: -14.8, mag: 3.3}, {ra: 82.2, dec: -17.8, mag: 2.6}]
                ]
            },
            {
                name: "南鱼座",
                center: { ra: 342.0, dec: -30.0 },
                color: "rgba(173, 216, 230, 0.6)",
                lines: [
                    // 北落师门(Fomalhaut)及其微弱的鱼身
                    [{ra: 344.4, dec: -29.6, mag: 1.16}, {ra: 334.0, dec: -33.0, mag: 4.2}, {ra: 325.0, dec: -32.0, mag: 4.3}, {ra: 335.0, dec: -28.0, mag: 4.5}, {ra: 344.4, dec: -29.6, mag: 1.16}]
                ]
            },
            {
                name: "天箭座",
                center: { ra: 298.0, dec: 18.0 },
                color: "rgba(255, 255, 255, 0.5)",
                lines: [
                    // 银河中的“箭”：极其紧凑的直线加分叉
                    [{ra: 295.0, dec: 18.0, mag: 4.3}, {ra: 297.0, dec: 19.0, mag: 3.5}, {ra: 302.0, dec: 16.0, mag: 4.4}],
                    [{ra: 297.0, dec: 19.0, mag: 3.5}, {ra: 296.0, dec: 21.0, mag: 4.3}]
                ]
            },
            {
                name: "狐狸座",
                center: { ra: 300.0, dec: 25.0 },
                color: "rgba(245, 222, 179, 0.3)",
                lines: [
                    // 位于天鹅座下方的暗弱长线
                    [{ra: 288.0, dec: 24.0, mag: 4.4}, {ra: 312.0, dec: 28.0, mag: 4.5}]
                ]
            },
            {
                name: "小犬座",
                center: { ra: 115.0, dec: 5.0 },
                color: "rgba(255, 228, 181, 0.6)",
                lines: [
                    // 南河三(Procyon)与南河二，冬季大三角的支柱之一
                    [{ra: 114.8, dec: 5.2, mag: 0.34}, {ra: 111.0, dec: 8.3, mag: 2.9}]
                ]
            },
            {
                name: "麒麟座",
                center: { ra: 105.0, dec: 0.0 },
                color: "rgba(230, 230, 250, 0.2)",
                lines: [
                    // 猎户座和大犬座之间的“独角兽”，星体较暗
                    [{ra: 95.0, dec: -9.0, mag: 3.9}, {ra: 107.0, dec: -0.5, mag: 4.0}, {ra: 115.0, dec: -9.0, mag: 4.1}],
                    [{ra: 107.0, dec: -0.5, mag: 4.0}, {ra: 100.0, dec: 8.0, mag: 4.3}]
                ]
            },
            {
                name: "天鸽座",
                center: { ra: 85.0, dec: -35.0 },
                color: "rgba(240, 248, 255, 0.4)",
                lines: [
                    // 大犬座下方的“鸽子”
                    [{ra: 85.0, dec: -34.0, mag: 2.6}, {ra: 81.0, dec: -35.0, mag: 3.1}, {ra: 88.0, dec: -40.0, mag: 3.8}]
                ]
            },
            {
                name: "罗盘座",
                center: { ra: 135.0, dec: -30.0 },
                color: "rgba(192, 192, 192, 0.4)",
                lines: [
                    // 简单的三点连线
                    [{ra: 131.0, dec: -27.0, mag: 3.6}, {ra: 134.0, dec: -33.0, mag: 3.9}, {ra: 138.0, dec: -37.0, mag: 4.0}]
                ]
            },
            {
                name: "巨爵座",
                center: { ra: 170.0, dec: -15.0 },
                color: "rgba(255, 255, 240, 0.4)",
                lines: [
                    // 形状像一个带底座的奖杯
                    [{ra: 164.0, dec: -18.0, mag: 4.0}, {ra: 168.0, dec: -23.0, mag: 4.4}, {ra: 178.0, dec: -17.0, mag: 3.8}, {ra: 173.0, dec: -14.0, mag: 3.5}, {ra: 164.0, dec: -18.0, mag: 4.0}]
                ]
            },
            {
                name: "小狮座",
                center: { ra: 160.0, dec: 35.0 },
                color: "rgba(255, 222, 173, 0.3)",
                lines: [
                    // 狮子座上方的一个三角形
                    [{ra: 145.0, dec: 28.0, mag: 3.8}, {ra: 155.0, dec: 34.0, mag: 4.2}, {ra: 165.0, dec: 33.0, mag: 4.4}, {ra: 145.0, dec: 28.0, mag: 3.8}]
                ]
            },
            {
                name: "杜鹃座",
                center: { ra: 0.0, dec: -70.0 },
                color: "rgba(255, 127, 80, 0.4)",
                lines: [
                    // 南天极附近的显著星座，包含小麦哲伦云
                    [{ra: 335.0, dec: -60.0, mag: 2.8}, {ra: 358.0, dec: -65.0, mag: 4.2}, {ra: 10.0, dec: -70.0, mag: 4.3}]
                ]
            },
            {
                name: "孔雀座",
                center: { ra: 300.0, dec: -65.0 },
                color: "rgba(100, 149, 237, 0.5)",
                lines: [
                    // 孔雀十一（孔雀座α）及其伸展的尾部
                    [{ra: 306.7, dec: -56.7, mag: 1.9}, {ra: 278.0, dec: -62.0, mag: 3.4}, {ra: 280.0, dec: -70.0, mag: 3.6}]
                ]
            },
            {
                name: "六分仪座",
                center: { ra: 152.0, dec: -1.0 },
                color: "rgba(245, 245, 220, 0.3)",
                lines: [
                    // 位于狮子座和长蛇座之间的暗弱三角形
                    [{ra: 152.0, dec: -0.4, mag: 4.5}, {ra: 148.0, dec: -8.0, mag: 5.0}, {ra: 158.0, dec: -6.0, mag: 5.1}, {ra: 152.0, dec: -0.4, mag: 4.5}]
                ]
            },
            {
                name: "天鹤座",
                center: { ra: 340.0, dec: -45.0 },
                color: "rgba(224, 255, 255, 0.5)",
                lines: [
                    // 鹤的主干（北落师门以南显著星座）
                    [{ra: 332.1, dec: -47.0, mag: 1.7}, {ra: 340.0, dec: -43.0, mag: 2.1}, {ra: 348.0, dec: -46.0, mag: 3.0}, {ra: 347.0, dec: -54.0, mag: 3.5}]
                ]
            },
            {
                name: "豺狼座",
                center: { ra: 235.0, dec: -45.0 },
                color: "rgba(188, 143, 143, 0.4)",
                lines: [
                    // 半人马座和天蝎座之间的多边形
                    [{ra: 220.0, dec: -47.0, mag: 2.3}, {ra: 230.0, dec: -40.0, mag: 3.4}, {ra: 240.0, dec: -45.0, mag: 3.2}, {ra: 235.0, dec: -52.0, mag: 3.6}, {ra: 220.0, dec: -47.0, mag: 2.3}]
                ]
            },
            {
                name: "苍蝇座",
                center: { ra: 185.0, dec: -70.0 },
                color: "rgba(173, 216, 230, 0.4)",
                lines: [
                    // 南十字座下方的显著小星座
                    [{ra: 185.0, dec: -69.0, mag: 2.7}, {ra: 190.0, dec: -71.0, mag: 3.3}, {ra: 180.0, dec: -73.0, mag: 3.6}]
                ]
            },
            {
                name: "南冕座",
                center: { ra: 285.0, dec: -40.0 },
                color: "rgba(255, 215, 0, 0.3)",
                lines: [
                    // 人马座下方的“小王冠”圆弧
                    [{ra: 280.0, dec: -38.0, mag: 4.1}, {ra: 283.0, dec: -41.0, mag: 4.0}, {ra: 287.0, dec: -42.0, mag: 4.2}, {ra: 291.0, dec: -37.0, mag: 4.5}]
                ]
            },
            {
                name: "望远镜座",
                center: { ra: 285.0, dec: -50.0 },
                color: "rgba(192, 192, 192, 0.3)",
                lines: [
                    // 简单的折线结构
                    [{ra: 275.0, dec: -46.0, mag: 3.5}, {ra: 285.0, dec: -52.0, mag: 4.1}, {ra: 300.0, dec: -50.0, mag: 4.5}]
                ]
            },
            {
                name: "印第安座",
                center: { ra: 315.0, dec: -55.0 },
                color: "rgba(244, 164, 96, 0.4)",
                lines: [
                    // 天鹤座和孔雀座之间的连线
                    [{ra: 312.0, dec: -47.0, mag: 3.1}, {ra: 320.0, dec: -58.0, mag: 4.4}, {ra: 310.0, dec: -72.0, mag: 4.5}]
                ]
            },
            {
                name: "气泵座",
                center: { ra: 150.0, dec: -35.0 },
                color: "rgba(240, 255, 240, 0.2)",
                lines: [
                    // 极淡的折线
                    [{ra: 142.0, dec: -31.0, mag: 4.3}, {ra: 155.0, dec: -36.0, mag: 4.6}, {ra: 165.0, dec: -30.0, mag: 4.8}]
                ]
            },
            {
                name: "显微镜座",
                center: { ra: 315.0, dec: -35.0 },
                color: "rgba(211, 211, 211, 0.2)",
                lines: [
                    // 摩羯座和南鱼座之间的暗弱区域
                    [{ra: 310.0, dec: -33.0, mag: 4.7}, {ra: 315.0, dec: -41.0, mag: 4.9}, {ra: 325.0, dec: -36.0, mag: 5.1}]
                ]
            },
            {
                name: "绘架座",
                center: { ra: 85.0, dec: -50.0 },
                color: "rgba(176, 224, 230, 0.4)",
                lines: [
                    // 老人星下方的简单折线
                    [{ra: 102.0, dec: -49.0, mag: 3.3}, {ra: 85.0, dec: -52.0, mag: 3.6}, {ra: 72.0, dec: -62.0, mag: 4.0}]
                ]
            },
            {
                name: "剑鱼座",
                center: { ra: 75.0, dec: -65.0 },
                color: "rgba(255, 160, 122, 0.5)",
                lines: [
                    // 包含大麦哲伦云区域的骨架
                    [{ra: 65.0, dec: -55.0, mag: 3.3}, {ra: 82.0, dec: -65.0, mag: 4.3}, {ra: 62.0, dec: -70.0, mag: 4.8}]
                ]
            },
            {
                name: "时钟座",
                center: { ra: 45.0, dec: -55.0 },
                color: "rgba(240, 248, 255, 0.3)",
                lines: [
                    // 波江座旁的狭长曲线
                    [{ra: 63.0, dec: -42.0, mag: 3.8}, {ra: 50.0, dec: -50.0, mag: 4.7}, {ra: 40.0, dec: -65.0, mag: 5.0}]
                ]
            },
            {
                name: "网罟座",
                center: { ra: 60.0, dec: -60.0 },
                color: "rgba(135, 206, 250, 0.4)",
                lines: [
                    // 完美的菱形小星座
                    [{ra: 58.0, dec: -57.0, mag: 3.3}, {ra: 66.0, dec: -62.0, mag: 3.8}, {ra: 55.0, dec: -67.0, mag: 4.4}, {ra: 47.0, dec: -62.0, mag: 4.5}, {ra: 58.0, dec: -57.0, mag: 3.3}]
                ]
            },
            {
                name: "南极座",
                center: { ra: 0.0, dec: -89.0 },
                color: "rgba(255, 255, 255, 0.2)",
                lines: [
                    // 包含天南极点的星座（虽然星很暗）
                    [{ra: 315.0, dec: -77.0, mag: 3.7}, {ra: 180.0, dec: -88.0, mag: 5.4}, {ra: 20.0, dec: -80.0, mag: 5.0}]
                ]
            },
            {
                name: "矩尺座",
                center: { ra: 240.0, dec: -50.0 },
                color: "rgba(211, 211, 211, 0.3)",
                lines: [
                    // 银河中的直角尺
                    [{ra: 243.0, dec: -42.0, mag: 4.0}, {ra: 240.0, dec: -50.0, mag: 4.4}, {ra: 248.0, dec: -60.0, mag: 4.6}]
                ]
            },
            {
                name: "圆规座",
                center: { ra: 220.0, dec: -60.0 },
                color: "rgba(224, 255, 255, 0.4)",
                lines: [
                    // 半人马座旁的窄三角形
                    [{ra: 221.0, dec: -59.0, mag: 3.2}, {ra: 212.0, dec: -63.0, mag: 4.1}, {ra: 230.0, dec: -65.0, mag: 4.5}, {ra: 221.0, dec: -59.0, mag: 3.2}]
                ]
            },
            {
                name: "蝘蜓座",
                center: { ra: 165.0, dec: -80.0 },
                color: "rgba(144, 238, 144, 0.3)",
                lines: [
                    // 极区附近的菱形
                    [{ra: 125.0, dec: -77.0, mag: 4.1}, {ra: 160.0, dec: -79.0, mag: 4.1}, {ra: 200.0, dec: -82.0, mag: 4.4}, {ra: 160.0, dec: -83.0, mag: 4.5}, {ra: 125.0, dec: -77.0, mag: 4.1}]
                ]
            },
            {
                name: "飞鱼座",
                center: { ra: 125.0, dec: -70.0 },
                color: "rgba(173, 216, 230, 0.4)",
                lines: [
                    // 船底座下方的交叉形状
                    [{ra: 105.0, dec: -68.0, mag: 4.0}, {ra: 135.0, dec: -72.0, mag: 3.8}],
                    [{ra: 110.0, dec: -75.0, mag: 3.9}, {ra: 125.0, dec: -65.0, mag: 4.2}]
                ]
            },
            {
                name: "山案座",
                center: { ra: 85.0, dec: -75.0 },
                color: "rgba(245, 245, 245, 0.2)",
                lines: [
                    // 全天最暗星座之一，紧邻南极座
                    [{ra: 100.0, dec: -71.0, mag: 5.1}, {ra: 85.0, dec: -77.0, mag: 5.2}, {ra: 60.0, dec: -75.0, mag: 5.4}]
                ]
            },
            // 以下为补全 88 星座的剩余微小星座
            {
                name: "雕具座", center: { ra: 70.0, dec: -38.0 }, color: "rgba(200,200,200,0.2)",
                lines: [[{ra: 68.0, dec: -36.0, mag: 4.4}, {ra: 75.0, dec: -41.0, mag: 5.0}]]
            },
            {
                name: "雕塑家座", center: { ra: 0.0, dec: -30.0 }, color: "rgba(200,200,200,0.2)",
                lines: [[{ra: 350.0, dec: -25.0, mag: 4.3}, {ra: 5.0, dec: -30.0, mag: 4.5}, {ra: 20.0, dec: -38.0, mag: 4.8}]]
            },
            {
                name: "罗盘座", center: { ra: 135.0, dec: -30.0 }, color: "rgba(200,200,200,0.2)",
                lines: [[{ra: 132.0, dec: -25.0, mag: 3.7}, {ra: 135.0, dec: -32.0, mag: 3.9}]]
            },
            {
                name: "显微镜座", center: { ra: 315.0, dec: -35.0 }, color: "rgba(200,200,200,0.2)",
                lines: [[{ra: 310.0, dec: -32.0, mag: 4.7}, {ra: 320.0, dec: -40.0, mag: 4.9}]]
            },
            {
                name: "望远镜座", center: { ra: 285.0, dec: -50.0 }, color: "rgba(200,200,200,0.2)",
                lines: [[{ra: 275.0, dec: -46.0, mag: 3.5}, {ra: 285.0, dec: -52.0, mag: 4.1}]]
            },
            {
                name: "天燕座", center: { ra: 240.0, dec: -75.0 }, color: "rgba(255,200,200,0.3)",
                lines: [[{ra: 210.0, dec: -78.0, mag: 3.8}, {ra: 260.0, dec: -77.0, mag: 4.2}, {ra: 275.0, dec: -70.0, mag: 4.4}]]
            },
            {
                name: "水蛇座", center: { ra: 30.0, dec: -70.0 }, color: "rgba(150,255,150,0.3)",
                lines: [[{ra: 5.0, dec: -60.0, mag: 2.8}, {ra: 40.0, dec: -65.0, mag: 4.1}, {ra: 60.0, dec: -75.0, mag: 3.4}]]
            },
            {
                name: "小马座", center: { ra: 318.0, dec: 5.0 }, color: "rgba(200,200,200,0.3)",
                lines: [[{ra: 317.0, dec: 4.0, mag: 3.9}, {ra: 319.0, dec: 9.0, mag: 4.5}]]
            }
        ],
        
        defaultBodiesRaw: [
            {"name":"太阳","color":"#fff5ce","mass":"1.0","radius":"695700","x":"0","y":"0","vx":"0","vy":"0","obliquity":"0","baseTemp":"5500"},
            {"name":"水星","color":"#a5a5a5","mass":"0.000000166","radius":"2439","x":"0.387","y":"0","vx":"0","vy":"10.12","obliquity":"0.03","baseTemp":"167"},
            {"name":"金星","color":"#e3bb76","mass":"0.000002447","radius":"6051","x":"0.723","y":"0","vx":"0","vy":"7.38","obliquity":"177.3","baseTemp":"464"},
            {"name":"地球","color":"#2271b3","mass":"0.000003003","radius":"6371","x":"1","y":"0","vx":"0","vy":"6.283","obliquity":"23.44","baseTemp":"15"},
            {"name":"月球","color":"#999999","mass":"0.0000000369","radius":"1737","x":"1.00257","y":"0","vx":"0","vy":"6.499","obliquity":"1.54","baseTemp":"-20"},
            {"name":"火星","color":"#e27b58","mass":"0.000000321","radius":"3389","x":"1.524","y":"0","vx":"0","vy":"5.08","obliquity":"25.19","baseTemp":"-65"},
            {"name":"木星","color":"#d39c7e","mass":"0.0009543","radius":"69911","x":"5.203","y":"0","vx":"0","vy":"2.76","obliquity":"3.13","baseTemp":"-110"},
            {"name":"土星","color":"#c5ab6e","mass":"0.0002857","radius":"58232","x":"9.537","y":"0","vx":"0","vy":"2.04","obliquity":"26.73","baseTemp":"-140"},
            {"name":"天王星","color":"#b5e1e2","mass":"0.00004366","radius":"25362","x":"19.191","y":"0","vx":"0","vy":"1.43","obliquity":"97.77","baseTemp":"-195"},
            {"name":"海王星","color":"#6081ff","mass":"0.00005151","radius":"24622","x":"30.068","y":"0","vx":"0","vy":"1.14","obliquity":"28.32","baseTemp":"-201"}
        ],

        init: function() {
            this.bodies = [];
            const sunData = this.defaultBodiesRaw.find(b => parseFloat(b.x) === 0);
            if (sunData) {
                this.bodies.push({...sunData, mass: parseFloat(sunData.mass), radius: parseFloat(sunData.radius), x: 0, y: 0, vx: 0, vy: 0, obliquity: parseFloat(sunData.obliquity), rotation: 0});
            }

            const planetsData = this.defaultBodiesRaw.filter(b => parseFloat(b.x) !== 0 && b.name !== "月球");
            planetsData.forEach(b => {
                const dist = parseFloat(b.x), speed = parseFloat(b.vy), angle = Math.random() * Math.PI * 2;
                this.bodies.push({
                    name: b.name, color: b.color, mass: parseFloat(b.mass), radius: parseFloat(b.radius),
                    x: dist * Math.cos(angle), y: dist * Math.sin(angle),
                    vx: -speed * Math.sin(angle), vy: speed * Math.cos(angle),
                    obliquity: parseFloat(b.obliquity), rotation: Math.random() * Math.PI * 2
                });
            });

            const moonData = this.defaultBodiesRaw.find(b => b.name === "月球");
            const earth = this.bodies.find(b => b.name === "地球");
            if (moonData && earth) {
                const relDist = 0.00257, relSpeed = 0.216, moonAngle = Math.random() * Math.PI * 2;
                this.bodies.push({
                    name: moonData.name, color: moonData.color, mass: parseFloat(moonData.mass), radius: parseFloat(moonData.radius),
                    x: earth.x + relDist * Math.cos(moonAngle), y: earth.y + relDist * Math.sin(moonAngle),
                    vx: earth.vx - relSpeed * Math.sin(moonAngle), vy: earth.vy + relSpeed * Math.cos(moonAngle),
                    obliquity: parseFloat(moonData.obliquity), rotation: Math.random() * Math.PI * 2
                });
            }
        },

        update: function() {
            const dt = (0.1 / 525600);
            const minutesPerFrame = this._minutesPerSecond / 60;
            const iterations = Math.ceil(minutesPerFrame);
            const stepDt = dt * (minutesPerFrame / iterations);

            for (let s = 0; s < iterations; s++) {
                let accels = this.bodies.map(() => ({ ax: 0, ay: 0 }));
                for (let i = 0; i < this.bodies.length; i++) {
                    for (let j = i + 1; j < this.bodies.length; j++) {
                        let b1 = this.bodies[i], b2 = this.bodies[j];
                        let dx = b2.x - b1.x, dy = b2.y - b1.y;
                        let r2 = dx * dx + dy * dy || 1e-9;
                        let r = Math.sqrt(r2);
                        let f = this.G * b1.mass * b2.mass / r2;
                        accels[i].ax += f * dx / r / b1.mass;
                        accels[i].ay += f * dy / r / b1.mass;
                        accels[j].ax -= f * dx / r / b2.mass;
                        accels[j].ay -= f * dy / r / b2.mass;
                    }
                }
                this.bodies.forEach((b, i) => {
                    b.vx += accels[i].ax * stepDt; b.vy += accels[i].ay * stepDt;
                    b.x += b.vx * stepDt; b.y += b.vy * stepDt;
                    if (b.name !== '太阳') b.rotation = (b.rotation + 2 * Math.PI * 365.25 * stepDt) % (Math.PI * 2);
                });
            }
        },

        getAltAz: function(targetName) {
            const obs = this.bodies.find(b => b.name === this.observerConfig.body) || this.bodies[3];
            const tar = this.bodies.find(b => b.name === targetName);
            if (!obs || !tar || obs === tar) return { alt: -90, az: 0, dist: 1 };

            let dx = tar.x - obs.x, dy = tar.y - obs.y;
            let d = Math.sqrt(dx*dx + dy*dy) || 0.001;
            let obl = obs.obliquity * Math.PI / 180;
            let y1 = dy * Math.cos(obl), z1 = dy * Math.sin(obl);
            let rot = (obs.rotation + this.observerConfig.lon * Math.PI / 180);
            let x2 = dx * Math.cos(rot) + y1 * Math.sin(rot);
            let y2 = -dx * Math.sin(rot) + y1 * Math.cos(rot);
            let latRad = this.observerConfig.lat * Math.PI / 180;
            let xH = -x2 * Math.sin(latRad) + z1 * Math.cos(latRad);
            let zH = x2 * Math.cos(latRad) + z1 * Math.sin(latRad);

            return { alt: Math.asin(zH/d)*180/Math.PI, az: Math.atan2(y2, xH)*180/Math.PI, dist: d };
        },

        getRADecAltAz: function(ra, dec) {
            const obs = this.bodies.find(b => b.name === this.observerConfig.body) || this.bodies[3];
            if (!obs) return { alt: -90, az: 0 };
            let raRad = ra * Math.PI / 180, decRad = dec * Math.PI / 180;
            let dx = Math.cos(decRad) * Math.cos(raRad), y1 = Math.cos(decRad) * Math.sin(raRad), z1 = Math.sin(decRad);
            let rot = (obs.rotation + this.observerConfig.lon * Math.PI / 180);
            let x2 = dx * Math.cos(rot) + y1 * Math.sin(rot), y2 = -dx * Math.sin(rot) + y1 * Math.cos(rot);
            let latRad = this.observerConfig.lat * Math.PI / 180;
            let xH = -x2 * Math.sin(latRad) + z1 * Math.cos(latRad), zH = x2 * Math.cos(latRad) + z1 * Math.sin(latRad);

            return { alt: Math.asin(zH) * 180 / Math.PI, az: Math.atan2(y2, xH) * 180 / Math.PI };
        }
    };

    //=============================================================================
    // 渲染循环
    //=============================================================================
    const DonaTheme = {
        bg: '#0f051a',
        primary: '#ff00ff',   // 玫红
        secondary: '#00ffff', // 青色
        highlight: '#ffff00', // 明黄
        grid: 'rgba(0, 255, 255, 0.12)',
        glitchOpacity: 0.15
    };

    /**
     * 绘制带色差效果的菱形（多娜多娜核心元素）
     * 替代原有的 drawGlowPoint
     */
    function drawDonaPoint(ctx, x, y, size, color, isGlitch = false) {
        ctx.save();
        ctx.translate(x, y);
        ctx.rotate(Math.PI / 4); // 旋转45度形成菱形

        // 使用 screen 混合模式实现色差
        ctx.globalCompositeOperation = 'screen';

        // 1. 青色层偏移
        ctx.fillStyle = DonaTheme.secondary;
        ctx.fillRect(-size + 1.5, -size, size * 2, size * 2);

        // 2. 玫红层偏移
        ctx.fillStyle = DonaTheme.primary;
        ctx.fillRect(-size - 1.5, -size, size * 2, size * 2);

        // 3. 核心亮色层
        ctx.fillStyle = "#fff";
        ctx.fillRect(-size * 0.5, -size * 0.5, size, size);

        ctx.restore();
    }

    //=============================================================================
    // 渲染循环 (包含文字名称)
    //=============================================================================
    function renderCanvas() {
        const w = canvas.width, h = canvas.height;
        const centerX = w / 2, centerY = h / 2;
        const maxRadius = Math.max(w, h) * 0.8;
        const pixelsPerDegree = maxRadius / 90;

        // 1. 绘制背景：深色底 + 动态网格
        ctx.fillStyle = DonaTheme.bg;
        ctx.fillRect(0, 0, w, h);

        // 绘制扫描网格
        ctx.strokeStyle = DonaTheme.grid;
        ctx.lineWidth = 1;
        ctx.beginPath();
        for (let x = 0; x < w; x += 60) { ctx.moveTo(x, 0); ctx.lineTo(x, h); }
        for (let y = 0; y < h; y += 60) { ctx.moveTo(0, y); ctx.lineTo(w, y); }
        ctx.stroke();

        // 随机 Glitch 色块偏移
        if (Math.random() > 0.96) {
            ctx.fillStyle = `rgba(255, 0, 255, ${DonaTheme.glitchOpacity})`;
            ctx.fillRect(0, Math.random() * h, w, 20);
        }

        // 2. 绘制星座与连线
        CelestialManager.CONSTELLATIONS.forEach(cons => {
            let labelPos = null;

            ctx.save();
            ctx.strokeStyle = DonaTheme.secondary;
            ctx.lineWidth = 1.5;
            ctx.setLineDash([2, 4]); // 科技感虚线

            cons.lines.forEach(path => {
                let isFirst = true;
                ctx.beginPath();
                path.forEach(pt => {
                    // 调用你原有的物理坐标逻辑[cite: 1]
                    let p = CelestialManager.getRADecAltAz(pt.ra, pt.dec);
                    if (p.alt >= 0) {
                        let r = (1.0 - (p.alt / 90)) * maxRadius;
                        let theta = (p.az - 90) * Math.PI * 2 / 360;
                        let sx = centerX + r * Math.cos(theta), sy = centerY + r * Math.sin(theta);
                        if (isFirst) { ctx.moveTo(sx, sy); isFirst = false; }
                        else { ctx.lineTo(sx, sy); }
                        if (!labelPos) labelPos = {x: sx, y: sy};
                    } else { isFirst = true; }
                });
                ctx.stroke();
            });
            ctx.restore();

            // 绘制星体节点（物理星等映射）
            cons.lines.forEach(path => {
                path.forEach(pt => {
                    let p = CelestialManager.getRADecAltAz(pt.ra, pt.dec);
                    if (p.alt > 0) {
                        let r = (1.0 - (p.alt / 90)) * maxRadius;
                        let theta = (p.az - 90) * Math.PI * 2 / 360;
                        let sx = centerX + r * Math.cos(theta), sy = centerY + r * Math.sin(theta);
                        const mag = pt.mag || 2.5;
                        const size = Math.max(1, 4 - mag * 0.5);
                        drawDonaPoint(ctx, sx, sy, size);
                    }
                });
            });

            if (labelPos) {
                ctx.fillStyle = DonaTheme.highlight;
                ctx.font = "bold 10px monospace";
                ctx.fillText(cons.name.toUpperCase() + ".sys", labelPos.x + 8, labelPos.y - 8);
            }
        });

        // 3. 渲染行星、太阳、月球
        const earth = CelestialManager.bodies.find(ob => ob.name === "地球");
        const sun = CelestialManager.bodies.find(ob => ob.name === "太阳");

        CelestialManager.bodies.forEach(b => {
            const obsBody = CelestialManager.bodies.find(ob => ob.name === CelestialManager.observerConfig.body);
            if (b === obsBody) return;

            let p = CelestialManager.getAltAz(b.name);
            if (p.alt < 0) return;

            let r = (1.0 - (p.alt / 90)) * maxRadius;
            let theta = (p.az - 90) * Math.PI * 2 / 360;
            let sx = centerX + r * Math.cos(theta), sy = centerY + r * Math.sin(theta);

            // 天体尺寸计算逻辑保持不变
            let distKm = p.dist * 149597870;
            let angularRadiusDeg = (b.radius / distKm) * (180 / Math.PI);
            let pixelRadius = Math.max(2, angularRadiusDeg * pixelsPerDegree * 15);

            // 使用多娜多娜风格渲染天体
            if (b.name === "太阳") {
                drawDonaPoint(ctx, sx, sy, pixelRadius, DonaTheme.highlight);
                // 额外光晕
                ctx.strokeStyle = DonaTheme.highlight;
                ctx.setLineDash([]);
                ctx.strokeRect(sx - pixelRadius - 5, sy - pixelRadius - 5, pixelRadius*2 + 10, pixelRadius*2 + 10);
            } else {
                drawDonaPoint(ctx, sx, sy, pixelRadius, b.color);
            }

            // 天体 UI 标签
            ctx.fillStyle = "#fff";
            ctx.font = "12px 'Segoe UI', Consolas, monospace";
            ctx.fillText(`[ ${b.name.toUpperCase()} ]`, sx + pixelRadius + 12, sy + 4);

            // 绘制辅助线连接到名称
            ctx.strokeStyle = "rgba(255,255,255,0.3)";
            ctx.beginPath();
            ctx.moveTo(sx + pixelRadius, sy);
            ctx.lineTo(sx + pixelRadius + 10, sy);
            ctx.stroke();
        });

        // 4. 全局 UI 装饰
        drawGlobalUI(ctx, w, h);
    }

    function drawGlobalUI(ctx, w, h) {
        ctx.fillStyle = DonaTheme.primary;
  
     

      

        // 右下角装饰条
        ctx.fillStyle = DonaTheme.highlight;
        for(let i=0; i<5; i++) {
            ctx.fillRect(w - 100 + (i*15), h - 40, 10, 4);
        }
    }

    // 启动物理与渲染主循环
    CelestialManager.init();
    // 在 CelestialManager.init() 之后添加
    const Keys = { up: false, down: false, left: false, right: false };
    window.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowUp') Keys.up = true;
        if (e.key === 'ArrowDown') Keys.down = true;
        if (e.key === 'ArrowLeft') Keys.left = true;
        if (e.key === 'ArrowRight') Keys.right = true;
    });
    window.addEventListener('keyup', (e) => {
        if (e.key === 'ArrowUp') Keys.up = false;
        if (e.key === 'ArrowDown') Keys.down = false;
        if (e.key === 'ArrowLeft') Keys.left = false;
        if (e.key === 'ArrowRight') Keys.right = false;
    });

    function handleInput() {
        const step = 0.5; // 每次移动0.5度
        if (Keys.up) CelestialManager.observerConfig.lat = Math.min(90, CelestialManager.observerConfig.lat + step);
        if (Keys.down) CelestialManager.observerConfig.lat = Math.max(-90, CelestialManager.observerConfig.lat - step);
        if (Keys.left) CelestialManager.observerConfig.lon -= step;
        if (Keys.right) CelestialManager.observerConfig.lon += step;
    }
    function gameLoop() {
        handleInput();
        CelestialManager.update();
        renderCanvas();
        requestAnimationFrame(gameLoop); // 浏览器原生的 60FPS 循环调用
    }
    gameLoop();
});