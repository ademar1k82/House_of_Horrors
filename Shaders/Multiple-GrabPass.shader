Shader "Custom/Multiple-GrabPass" {
    Properties {
        // Define shader properties with default values
        _Intensity ("Distortion Intensity", Range(0, 50)) = 0
        [Toggle] _UseDistortion ("Use Distortion", float) = 0

        _PixelNumberX ("Pixel number along X", float) = 500
        _PixelNumberY ("Pixel number along Y", float) = 500      
        [Toggle] _UsePixelation ("Use Pixelation", float) = 0

        _Saturation ("Color Saturation", Range(0, 3)) = 1
        _Brightness ("Color Brightness", Range(0, 3)) = 1
        _ColorSpeed ("Color Speed", float) = 1
        [Toggle] _UseColorEffect ("Use Color Effect", float) = 0

        _NoiseIntensity ("Noise Intensity", Range(0, 1)) = 0
        _NoiseScale ("Noise Scale", Range(0.1, 10)) = 1
        [Toggle] _UseNoise ("Use Noise", float) = 0
        _NoiseSpeed ("Noise Speed", Range(0, 10)) = 1
    }

    SubShader {
        // Define the rendering order and type
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        // Grab the current screen content to _GrabTexture
        GrabPass { "_GrabTexture" }

        Pass {
            // Disable writing to the depth buffer and set blending mode
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Function to generate Perlin noise
            float2 PerlinNoise(float2 uv, float time) {
                return float2(
                    frac(sin(dot(uv, float2(12.9898, 78.233)) + time) * 43758.5453),
                    frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0) + time) * 43758.5453)
                );
            }

            // Define the structure to pass data from vertex to fragment shader
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
            };

            // Define shader properties
            sampler2D _GrabTexture;
            float _Intensity;
            float _PixelNumberX;
            float _PixelNumberY;
            float _UseDistortion;
            float _UsePixelation;
            float _UseColorEffect;
            float _UseNoise;
            float _Saturation;
            float _Brightness;
            float _ColorSpeed;
            float _NoiseIntensity;
            float _NoiseScale;
            float _NoiseSpeed;
            float4 _MainTex_ST;

            // Vertex shader
            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            // Fragment shader
            half4 frag(v2f i) : SV_Target {
                float2 grabUV = i.grabPos.xy / i.grabPos.w;
                half4 baseColor = tex2D(_GrabTexture, grabUV);

                // Apply distortion effect
                if (_UseDistortion > 0.5) {
                    grabUV.x += sin((_Time.y + grabUV.y) * _Intensity) / 20.0;
                    baseColor = tex2D(_GrabTexture, grabUV);
                }

                // Apply pixelation effect
                if (_UsePixelation > 0.5) {
                    float pixelSizeX = 1.0 / _PixelNumberX;
                    float pixelSizeY = 1.0 / _PixelNumberY;
                    float2 pixelatedUV = float2(floor(grabUV.x / pixelSizeX) * pixelSizeX, floor(grabUV.y / pixelSizeY) * pixelSizeY);
                    baseColor = tex2D(_GrabTexture, pixelatedUV);
                }

                // Apply color effect
                if (_UseColorEffect > 0.5) {
                    // Saturation adjustment
                    float3 gray = dot(baseColor.rgb, float3(0.3, 0.59, 0.11));
                    baseColor.rgb = lerp(gray, baseColor.rgb, _Saturation);

                    // Brightness adjustment
                    baseColor.rgb *= _Brightness;

                    // Apply dynamic color pattern
                    float3 dynamicColor = float3(
                        0.5 + 0.5 * sin(_ColorSpeed * _Time.y),
                        0.5 + 0.5 * sin(_ColorSpeed * _Time.y + 1.0),
                        0.5 + 0.5 * sin(_ColorSpeed * _Time.y + 2.0)
                    );

                    baseColor.rgb *= dynamicColor;

                    // Invert specific colors
                    if (baseColor.r > 0.9 && baseColor.g > 0.9 && baseColor.b > 0.9) {
                        // Replace whites with reds
                        baseColor.rgb = float3(1.0, 0.0, 0.0);
                    } else if (baseColor.r > 0.9 && baseColor.g > 0.9) {
                        // Replace yellows with blues
                        baseColor.rgb = float3(0.0, 0.0, 1.0);
                    } else if (baseColor.r > 0.9 && baseColor.b > 0.9) {
                        // Replace reds with greens
                        baseColor.rgb = float3(0.0, 1.0, 0.0);
                    } else if (baseColor.g > 0.9 && baseColor.b > 0.9) {
                        // Replace blues with purples
                        baseColor.rgb = float3(1.0, 0.0, 1.0);
                    } else if (baseColor.r > 0.9) {
                        // Replace browns with yellows
                        baseColor.rgb = float3(1.0, 1.0, 0.0);
                    }
                }

                // Apply noise effect
                if (_UseNoise > 0.5 && _NoiseIntensity > 0) {
                    // Add noise to UV coordinates
                    float time = _Time.y * _NoiseSpeed;
                    float2 noise = PerlinNoise(i.uv * _NoiseScale, time);
                    float noiseIntensity = _NoiseIntensity;
                    float2 distortion = (_Intensity / 100.0) * (noise - 0.5);
                    grabUV += distortion * noiseIntensity;
                    half4 noiseColor = tex2D(_GrabTexture, grabUV);

                    // Combine noise and base color
                    baseColor.rgb = lerp(baseColor.rgb, noiseColor.rgb, noiseIntensity);
                }

                return baseColor;
            }
            ENDCG
        }
    }
    // Use Diffuse shader as a fallback
    FallBack "Diffuse"
}