from PIL import Image, ImageDraw, ImageFont
import os

# Create a 1024x1024 image
size = 1024
image = Image.new('RGB', (size, size))
draw = ImageDraw.Draw(image)

# Create gradient background (blue to purple)
for y in range(size):
    # Linear interpolation from blue to purple
    r = int(37 + (124 - 37) * y / size)   # 37 (0x25) -> 124 (0x7c)
    g = int(99 + (58 - 99) * y / size)    # 99 (0x63) -> 58 (0x3a)  
    b = int(235 + (237 - 235) * y / size) # 235 (0xeb) -> 237 (0xed)
    
    color = (r, g, b)
    draw.line([(0, y), (size, y)], fill=color)

# Add rounded rectangle effect by drawing corner masks
corner_radius = 120
mask = Image.new('L', (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.rounded_rectangle([0, 0, size, size], radius=corner_radius, fill=255)

# Apply the mask
output = Image.new('RGB', (size, size), (255, 255, 255))
output.paste(image, mask=mask)

# Add text 'NS' in center
try:
    # Try to create a font (fallback to default if unavailable)
    font_size = 350
    try:
        font = ImageFont.truetype('arial.ttf', font_size)
    except:
        font = ImageFont.load_default()
        
    text = 'NS'
    
    # Get text dimensions
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Calculate position to center text
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 30
    
    # Draw text shadow
    shadow_offset = 6
    draw_final = ImageDraw.Draw(output)
    draw_final.text((x + shadow_offset, y + shadow_offset), text, fill=(0, 0, 0, 100), font=font)
    draw_final.text((x, y), text, fill=(255, 255, 255), font=font)
    
except Exception as e:
    print(f'Font error: {e}')
    # Draw simple shapes as fallback
    center = size // 2
    draw_final = ImageDraw.Draw(output)
    
    # Draw N
    draw_final.rectangle([center-150, center-100, center-100, center+100], fill=(255, 255, 255))
    draw_final.rectangle([center-100, center-100, center-50, center-50], fill=(255, 255, 255))
    draw_final.rectangle([center-50, center-100, center, center+100], fill=(255, 255, 255))
    
    # Draw S
    draw_final.rectangle([center+50, center-100, center+150, center-50], fill=(255, 255, 255))
    draw_final.rectangle([center+50, center-25, center+150, center+25], fill=(255, 255, 255))
    draw_final.rectangle([center+50, center+50, center+150, center+100], fill=(255, 255, 255))

# Save the image
output_path = r'c:\Users\nitis\Desktop\Build Production\NitishSingh\flutter_portfolio\assets\icons\app_icon.png'
output.save(output_path, 'PNG', quality=95)
print(f'App icon created successfully at: {output_path}')
