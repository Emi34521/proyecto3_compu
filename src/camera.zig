const rl = @import("raylib");
const std = @import("std");

pub const Camera = struct {
    Postition: rl.Vector3,
    Forward: rl.Vector3,
    Right: rl.Vector3,
    Up: rl.Vector3,

    pub fn init(position: rl.Vector3, target: rl.Vector3) Camera {
        var out = Camera{
            .Forward = .zero(), //Se va a reemplazar
            .Postition = position,
            .Right = .{ .x = 1, .y = 0, .z = 0 },
            .Up = .{ .x = 0, .y = 1, .z = 0 },
        };
        out.lookAt(target);
        return out;
    }

    //https://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/lookat-function//framing-lookat-function.html
    pub fn lookAt(self: *Camera, target: rl.Vector3) void {
        // 100% bien
        self.Forward = target.subtract(self.Postition).normalize();

        // Luego usamos producto cruz para sacar al vector que define
        // a la derecha porque eso nos dará un vector normal al plano
        // definido por forward y algún otro vector, y eso hará que right sea
        // perpendicular a ambos.
        // Como vector de referencia se usa el vertical fijo del mundo (0, 1, 0) y no el up
        // anterior de la cámara: así la cámara nunca se inclina de lado y no se acumula error.
        // Solo falla si forward es exactamente vertical, por eso el pitch se limita en main.
        // El orden del operación importa, si ponemos Forward primero, calcularmos Left, no Right
        const world_up = rl.Vector3{ .x = 0, .y = 1, .z = 0 };
        self.Right = rl.Vector3.crossProduct(world_up, self.Forward).normalize();

        // En este caso, Up sí cumplirá con ser 100% perpendicular a right y forward,
        // pero tiene el error transitivo de right.
        // De nuevo, el orden importa, si ponemos Right primero, calcularmos Down, no Up
        self.Up = rl.Vector3.crossProduct(self.Forward, self.Right).normalize();
    }
};
