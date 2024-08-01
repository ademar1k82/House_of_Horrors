Shader "Hidden/Sobel-Gaussian"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // Main texture
        _Resolution ("Resolution", Vector) = (1920, 1080, 0, 0) // Resolution of the screen
        _TransitionFactor ("Transition Factor", Range(-0.1, 1.1)) = 1.1 // Transition factor for the effect
        _Color1 ("Color 1", Color) = (1, 1, 1, 1) // First color for the effect
        _Color2 ("Color 2", Color) = (1, 1, 1, 1) // Second color for the effect
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Define the properties
            sampler2D _MainTex;
            float4 _Resolution;
            float _TransitionFactor;
            fixed4 _Color1;
            fixed4 _Color2;

            // Define the vertex data structure
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Define the output structure of the vertex shader
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Sobel filter function
            float SobelFilter(float2 fragCoord)
            {
                // Define the Sobel filter kernels
                float3 sobelY[3] = {float3(-1, 0, 1), float3(-2, 0, 2), float3(-1, 0, 1)};
                float3 sobelX[3] = {float3(-1, -2, -1), float3(0, 0, 0), float3(1, 2, 1)};
                float sumX = 0.0;
                float sumY = 0.0;

                // Apply the Sobel filter
                for (int i = -1; i <= 1; i++)
                {
                    for (int j = -1; j <= 1; j++)
                    {
                        float2 uvOffset = (fragCoord + float2(i, j)) / _Resolution.xy;
                        float value = tex2D(_MainTex, uvOffset).r;
                        sumX += sobelX[i + 1][j + 1] * value;
                        sumY += sobelY[i + 1][j + 1] * value;
                    }
                }

                // Calculate the filtered value
                float filteredValue = step(1.0 - sqrt(sumX * sumX + sumY * sumY), 0.3);
                return filteredValue;
            }

            // Gaussian filter function
            float GaussianFilter(float2 fragCoord)
            {
                // Define the Gaussian filter kernel
                float3 gaussian[3] = {float3(1, 2, 1), float3(2, 4, 2), float3(1, 2, 1)};
                float sumGaussian = 0.0;

                // Apply the Gaussian filter
                for (int i = -1; i <= 1; i++)
                {
                    for (int j = -1; j <= 1; j++)
                    {
                        float2 uvOffset = (fragCoord + float2(i, j)) / _Resolution.xy;
                        sumGaussian += gaussian[i + 1][j + 1] * tex2D(_MainTex, uvOffset).r;
                    }
                }

                return sumGaussian;
            }

            // Main image function
            float3 mainImage(float2 fragCoord)
            {
                float3 result = float3(0, 0, 0);

                // Loop over the pixel offsets
                for (int hOffset = 0; hOffset < 2; hOffset++)
                {
                    for (int vOffset = 0; vOffset < 2; vOffset++)
                    {
                        // Calculate the pixel offset
                        float2 pixelOffset = float2(hOffset, vOffset) / 2.0 - 0.5;
                        float2 uv = ((fragCoord + pixelOffset) * 2.0 - _Resolution.xy) / _Resolution.y;

                        // Calculate the chroma offset
                        float3 chromaOffset = float3(-2.5 + cos(uv.y * 1.0 + _Time.y * 3.0) * 2.0 + sin(uv.y + _Time.y * 5.0) * 0.8,
                                                     cos(uv.y + _Time.y * 3.0) * 1.0 + sin(uv.y + _Time.y * 5.0) * 0.8,
                                                     2.5 + sin(uv.y * 4.0 + _Time.y * 1.0) * 1.5 - cos(uv.x * 1.0 + _Time.y * 4.0) * 1.0);

                        // Initialize the color
                        float3 col = float3(0, 0, 0);

                        // Apply the filters
                        col.x = GaussianFilter(fragCoord * float2(1.01, 1.0) + float2(chromaOffset.x, 0.0));
                        col.y = SobelFilter(fragCoord + float2(chromaOffset.y, 0.0));
                        col.z = GaussianFilter(fragCoord * float2(1.01, 1.0) + float2(chromaOffset.z, 0.0));

                        // Calculate the color
                        float gaussFactor = abs(col.x - col.z);
                        float sobelFactor = col.y;
                        col = gaussFactor * _Color1.rgb + sobelFactor * _Color2.rgb;

                        // Add the color to the result
                        result += col;
                    }
                }

                // Normalize the result
                result /= 4.0;                       
                return result;
            }

            // Fragment shader
            fixed4 frag(v2f i) : SV_Target
            {
                // Get the original color
                float3 col = tex2D(_MainTex, i.uv);

                // Calculate the fragment coordinate
                float2 fragCoord = i.uv * _Resolution.xy;

                // Calculate the color
                float3 color = mainImage(fragCoord);

                // Calculate the transition
                float transition = smoothstep(_TransitionFactor - 0.1, _TransitionFactor + 0.1, fragCoord.x / _Resolution.x);

                // Return the final color
                return fixed4(lerp(col, color, transition), 1.0);            
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}