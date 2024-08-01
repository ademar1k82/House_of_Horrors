Shader "Custom/Triplanar/Terrain" 
{
    Properties {
        _Texture1 ("First Texture", 2D) = "white" {} // Renamed to First Texture
        _Texture2 ("Second Texture", 2D) = "white" {} // Renamed to Second Texture
        _Texture3 ("Third Texture", 2D) = "white" {} // Renamed to Third Texture
        _Scale ("Scaling Factor", Range(0.001, 1.0)) = 0.1 // Renamed to Scaling Factor
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        
        CGPROGRAM
        #pragma surface surf Standard

        sampler2D _Texture1; // Sampler for the first texture
        sampler2D _Texture2; // Sampler for the second texture
        sampler2D _Texture3; // Sampler for the third texture
        float _Scale; // Scaling factor

        struct Input {
            float2 uv_MainTex; // Main texture coordinates
            float3 worldNormal; // Normal vector in world space
            float3 worldPos; // Position in world space
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
            
            // Sample the textures using the world position and scale
            fixed4 col1 = tex2D(_Texture2, IN.worldPos.yz * _Scale);
            fixed4 col2 = tex2D(_Texture1, IN.worldPos.xz * _Scale);
            fixed4 col3 = tex2D(_Texture3, IN.worldPos.xy * _Scale);

            // Normalize the world normal vector
            float3 vec = abs(IN.worldNormal);
            vec /= vec.x + vec.y + vec.z + 0.001f;

            // Combine the colors based on the normal vector
            fixed4 col = vec.x * col1 + vec.y * col2 + vec.z * col3;

            // Set the albedo and emission colors
            o.Albedo = col;
            o.Emission = col;
        }

        ENDCG
    }
    FallBack "Diffuse" // Use Diffuse shader as a fallback
}