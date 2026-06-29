#version 440

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 uColor;
    float uAmp;
    float uFreq;
    float uPhase;
    float uTrackHeight;
    float uWidth;
} ubuf;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

void main() {
    highp vec2 uv = qt_TexCoord0;
    
    highp float pixelX = uv.x * ubuf.uWidth;
    
    highp float wave = 0.5 + sin((pixelX / ubuf.uFreq) + ubuf.uPhase) * ubuf.uAmp;
    
    lowp float line = step(wave - ubuf.uTrackHeight / 2.0, uv.y) 
                    * step(uv.y, wave + ubuf.uTrackHeight / 2.0);
    
    fragColor = ubuf.uColor * line * ubuf.qt_Opacity;
}
