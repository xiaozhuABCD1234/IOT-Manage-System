import colorsys


def hsv_to_rgb(h, s=0.9, v=0.9):
    """将HSV颜色空间转换为RGB颜色空间（0-255范围）"""
    rgb = colorsys.hsv_to_rgb(h / 360.0, s, v)
    return tuple(round(i * 255) for i in rgb)


def generate_colors(n):
    """生成N个均匀分布的色相颜色"""
    colors = []
    for i in range(n):
        hue = 360 * i / n  # 均匀分配色相角度
        rgb = hsv_to_rgb(hue)
        hex_color = "#%02x%02x%02x" % rgb
        colors.append(hex_color)
    return colors


if __name__ == "__main__":
    print(generate_colors(6))
