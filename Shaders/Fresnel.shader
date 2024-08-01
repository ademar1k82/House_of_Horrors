Shader "Unlit/Fresnel"
{
    Properties
    {
        _BaseTex ("Base Texture", 2D) = "white" {} // Main texture

        _DistortionTex ("Distortion Texture", 2D) = "white" {} // Distortion texture
        _DistortionStrength ("Distortion Strength", Range(0,10)) = 0 // Intensity of the distortion

        _OuterGlowColor ("Outer Glow Color", Color) = (1,1,1,1) // Color of the outer glow
        _OuterGlowPower ("Outer Glow Power", Range(0,10)) = 0 // Power of the outer glow
        _OuterGlowExponent ("Outer Glow Exponent", Range(0,10)) = 0 // Exponent of the outer glow

        _InnerGlowColor ("Inner Glow Color", Color) = (1,1,1,1) // Color of the inner glow
        _InnerGlowPower ("Inner Glow Power", Range(0,10)) = 0 // Power of the inner glow
        _InnerGlowExponent ("Inner Glow Exponent", Range(0,10)) = 0 // Exponent of the inner glow

        [Toggle] _UseNormalMap ("Use Normal Map", float) = 0 // Toggle for normal mapping
        _NormalMap ("Normal Map", 2D) = "white" {} // Normal map texture
    }
    SubShader
    {
        Tags { "RenderQueue"="Transparent" } // Set the render queue to transparent
        LOD 100 // Set the level of detail
        Blend SrcAlpha One // Set the blend mode
        Pass
        {
            CGPROGRAM
            #pragma vertex vert // Vertex shader
            #pragma fragment frag // Fragment shader
            #pragma multi_compile _USE_NORMAL_MAP // Compile-time directive for normal mapping
            #include "UnityCG.cginc" // Include common shader code

            // Define the input data structure
            struct appdata
            {
                float4 vertex : POSITION; // Vertex position
                float2 uv : TEXCOORD0; // Texture coordinates
                float3 normal : NORMAL; // Normal vector
                float3 tangent : TANGENT; // Tangent vector
            };

            // Define the output data structure
            struct v2f
            {
                float2 uv : TEXCOORD0; // Texture coordinates
                float4 vertex : SV_POSITION; // Vertex position
                float3 normal : TEXCOORD1; // Normal vector
                float3 viewDir : TEXCOORD2; // View direction vector
                float3 tangent : TEXCOORD3; // Tangent vector
                float3 bitangent : TEXCOORD4; // Bitangent vector
            };

            // Define the texture samplers and variables
            sampler2D _BaseTex, _NormalMap, _DistortionTex;
            float4 _BaseTex_ST, _OuterGlowColor, _InnerGlowColor;
            float _OuterGlowPower, _OuterGlowExponent, _DistortionStrength, _InnerGlowExponent, _InnerGlowPower;

            // Vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Convert the vertex position from object space to clip space
                o.normal = UnityObjectToWorldNormal(v.normal); // Convert the normal vector from object space to world space

                // If normal mapping is enabled
                #if _USE_NORMAL_MAP
                    o.tangent = UnityObjectToWorldDir(v.tangent); // Convert the tangent vector from object space to world space
                    o.bitangent = cross(o.tangent, o.normal); // Calculate the bitangent vector
                #endif

                o.viewDir = normalize(WorldSpaceViewDir(v.vertex)); // Calculate the view direction vector
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex); // Transform the texture coordinates
                return o;
            }

            // Fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate the distortion value
                float distortionValue = tex2D(_DistortionTex, i.uv + _Time.xx).r;

                // Calculate the final normal vector
                float3 finalNormal = i.normal;
                // If normal mapping is enabled
                #if _USE_NORMAL_MAP
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv)); // Unpack the normal map
                    finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal; // Calculate the final normal vector
                #endif

                // Calculate the outer glow amount
                float outerGlowAmount = 1 - max(0, dot(finalNormal, i.viewDir));
                outerGlowAmount *= distortionValue * _DistortionStrength;
                outerGlowAmount = pow(outerGlowAmount, _OuterGlowExponent) * _OuterGlowPower;
                float3 outerGlowColor = outerGlowAmount * _OuterGlowColor;

                // Calculate the inner glow amount
                float innerGlowAmount = max(0, dot(finalNormal, i.viewDir));
                innerGlowAmount *= distortionValue * _DistortionStrength;
                innerGlowAmount = pow(innerGlowAmount, _InnerGlowExponent) * _InnerGlowPower;
                float3 innerGlowColor = innerGlowAmount * _InnerGlowColor;

                // Calculate the final color
                float3 finalColor = outerGlowColor + innerGlowColor;
                return fixed4(finalColor, 1); // Return the final color
            }
            ENDCG
        }
    }
}