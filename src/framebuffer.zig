const rl = @import("raylib");

pub const Framebuffer = struct {
    width: i32,
    height: i32,
    color_buff: rl.Image,
    background_color: rl.Color,
    current_color: rl.Color,
    texture: ?rl.Texture = null,

    pub fn init(width: i32, height: i32, background_color: ?rl.Color, draw_color: ?rl.Color) Framebuffer {
        const bg_color = background_color orelse rl.Color.black;
        const color = draw_color orelse rl.Color.white;
        return .{
            .color_buff = rl.genImageColor(width, height, bg_color),
            .width = width,
            .height = height,
            .background_color = bg_color,
            .current_color = color,
        };
    }

    pub fn clear(self: *Framebuffer) void {
        self.color_buff.clearBackground(self.background_color);
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
        }
    }

    pub fn set_pixel(self: *Framebuffer, x: i32, y: i32, color: rl.Color) !void {
        if (x >= self.width or y >= self.height) return error.BadCoordinates;
        self.color_buff.drawPixel(x, y, color);
    }
    // funciones de dibujo creadas con ayuda de claude. Básicamente hacen un círculo, relleno del círculo y una línea horizontal.
    // Línea horizontal de x0 a x1 (inclusive) en la fila y. Los extremos se recortan una sola vez, no pixel por pixel.
    pub fn TM_linea_horizontal(self: *Framebuffer, x0: i32, x1: i32, y: i32, color: rl.Color) void {
        if (y < 0 or y >= self.height) return;
        const desde = @max(@min(x0, x1), 0);
        const hasta = @min(@max(x0, x1), self.width - 1);
        var x = desde;
        while (x <= hasta) : (x += 1) {
            self.color_buff.drawPixel(x, y, color);
        }
    }

    // Contorno de un círculo con el algoritmo del punto medio (Bresenham para círculos).
    // Solo calcula un octavo del círculo y refleja cada punto en los otros siete. Usa solo enteros.
    pub fn TM_circulo(self: *Framebuffer, cx: i32, cy: i32, radio: i32, color: rl.Color) !void {
        if (radio < 0) return;
        var x: i32 = 0;
        var y: i32 = radio;
        var d: i32 = 1 - radio; // decide si el siguiente pixel se queda en la misma fila o baja una
        while (x <= y) {
            try self.set_pixel(cx + x, cy + y, color);
            try self.set_pixel(cx - x, cy + y, color);
            try self.set_pixel(cx + x, cy - y, color);
            try self.set_pixel(cx - x, cy - y, color);
            try self.set_pixel(cx + y, cy + x, color);
            try self.set_pixel(cx - y, cy + x, color);
            try self.set_pixel(cx + y, cy - x, color);
            try self.set_pixel(cx - y, cy - x, color);
            if (d < 0) {
                d += 2 * x + 3;
            } else {
                d += 2 * (x - y) + 5;
                y -= 1;
            }
            x += 1;
        }
    }

    // Círculo relleno una línea horizontal por cada fila. El ancho de cada fila sale de x² + y² = r².
    // Cada pixel se pinta una sola vez, así que también funciona con colores semitransparentes.
    // Para dibujarlo con borde, llama primero a este y después a TM_circulo con otro color.
    pub fn TM_circulo_relleno(self: *Framebuffer, cx: i32, cy: i32, radio: i32, color: rl.Color) !void {
        if (radio < 0) return;
        const r2: i32 = radio * radio;
        var dy: i32 = -radio;
        while (dy <= radio) : (dy += 1) {
            const mitad: i32 = @intFromFloat(@round(@sqrt(@as(f32, @floatFromInt(r2 - dy * dy)))));
            self.TM_linea_horizontal(cx - mitad, cx + mitad, cy + dy, color);
        }
    }

    pub fn set_background_color(self: *Framebuffer, color: rl.Color) void {
        self.background_color = color;
    }

    pub fn set_current_color(self: *Framebuffer, color: rl.Color) void {
        self.current_color = color;
    }

    pub fn render_to_file(self: Framebuffer, filename: []const u8) !void {
        if (!self.color_buff.exportToFile(@ptrCast(filename))) return error.CouldntWriteFile;
    }

    pub fn swap_buffers(self: *Framebuffer) !void {
        rl.beginDrawing();
        defer rl.endDrawing();

        // Raylib maneja los conceptos de Image y Texture
        // En esencia son lo mismo, un buffer de color, o imagen.
        // Pero Image está en la RAM, mientras que Texture está en la VRAM.
        // (La RAM del CPU vs la del GPU)
        // Para que la GPU pueda operar sobre una imagen, esta tiene que estar en la VRAM.
        // En este caso, solo estamos cargando a la GPU la imagen que dibujamos para poder mostrarla.
        const texture = try rl.loadTextureFromImage(self.color_buff);
        rl.drawTexture(texture, 0, 0, .white);

        //Por lo general, el swap es entre 2 buffers. Uno es el que el usuario está viendo,
        //mientras que escribimos en el otro para preparar nuestro siguiente frame.
        //Cada uno de los frame buffers intercambian su rol.
        //Sobrescribir es mucho más amigable para la computadora que tener que estar malabareando la memoria
        //para crear, destruir y volver a crear buffers.

        //¡Pero como nosotros insistimos en usar el CPU para dibujar los frames, no podemos hacer eso!
        //Siempre tendremos que guardar la textura para luego poder borrarla en clean. Si no, nos quedamos sin memoria en la GPU.
        rl.drawFPS(10, 10); //dibujar fps
        self.texture = texture;
    }
};
