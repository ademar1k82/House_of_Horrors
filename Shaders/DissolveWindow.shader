Shader "Custom/DissolveWindow"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {} // Main texture of the shader
        _Color ("Color", Color) = (1,1,1,0) // Color of the shader
        _Glossiness ("Burned Scale", Range(-0.1,1)) = 0.0 // Controls the scale of the burned effect
        _SpecGlossMap ("Roughness Map (also used for the Burned Effect)", 2D) = "white" {} // Roughness map, also used for the burned effect
        _BumpMap ("Normal Map", 2D) = "bump" {} // Normal map for the shader
        _BurnMap ("Burn Map", 2D) = "white" {} // Burn map for the shader
    }
    SubShader
    {
        Tags { "RenderType"="Fade" } // Render type of the shader
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha // Surface shader with standard lighting model, support for forward shadows and alpha transparency
        #pragma target 3.0 // The shader will be compiled for a target with Shader Model 3.0

        sampler2D _MainTex;
        sampler2D _SpecGlossMap;
        sampler2D _BumpMap;
        sampler2D _BurnMap;

        struct Input
        {
            float2 uv_MainTex; // UV coordinates for the main texture
        };

        half _Glossiness; // Glossiness value
        fixed4 _Color; // Color value

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color; // Sample the main texture and multiply it by the color
            o.Normal = -UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex)); // Unpack the normal map and invert it
            fixed4 specGloss = tex2D(_SpecGlossMap, IN.uv_MainTex); // Sample the specular glossiness map
            fixed4 burn = tex2D(_BurnMap, IN.uv_MainTex) * specGloss * tex2D(_BumpMap, IN.uv_MainTex); // Calculate the burn effect
            o.Metallic = specGloss.g * 0; // Set the metallic property to 0

            // Dissolve effect
            float noise = burn.r;
            fixed steppedNoise = step(-_Glossiness, -noise); // Step function for the dissolve effect

            if (steppedNoise > 0.0)
            {
                discard; // Discard the pixel if the noise is greater than 0.0
            }

            o.Albedo = c.rgb; // Set the albedo to the RGB channels of the color
            o.Alpha = 0.66; // Set the alpha to 0.66
            o.Smoothness = specGloss; // Set the smoothness to the specular glossiness map
        }
        ENDCG
    }
    FallBack "Diffuse" // Fallback to diffuse shader if this shader fails
}