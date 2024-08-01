Shader "Custom/DissolveHouse"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {} // Main texture of the shader
        _Glossiness ("Burned Scale", Range(-0.1000,1)) = 0.5 // Controls the scale of the burned effect
        _SpecGlossMap ("Roughness Map (also used for the Burned Effect)", 2D) = "white" {} // Roughness map, also used for the burned effect
        _BumpMap ("Normal Map", 2D) = "bump" {} // Normal map for the shader
        _BurnMap ("Burn Map", 2D) = "white" {} // Burn map for the shader
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SpecGlossMap;
        sampler2D _BumpMap;
        sampler2D _BurnMap;

        struct Input
        {
            float2 uv_MainTex; // UV coordinates for the main texture
        };

        half _Glossiness; // Glossiness value

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex); // Sample the main texture
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex)); // Unpack the normal map
            fixed4 specGloss = tex2D(_SpecGlossMap, IN.uv_MainTex); // Sample the specular glossiness map
            fixed4 burn = tex2D(_BurnMap, IN.uv_MainTex) * specGloss * tex2D(_BumpMap, IN.uv_MainTex); // Calculate the burn effect
            o.Metallic = specGloss.g * 0; // Set the metallic property

            // Dissolve effect
            float noise = burn.r;
            fixed steppedNoise = step(_Glossiness, noise); // Step function for the dissolve effect

            fixed4 orange = float4(1, 0.2, 0, 1); // Orange color for the burn effect
            fixed4 grey = float4(0.2, 0.2, 0.2, 0.2); // Grey color for the burn effect

            if (steppedNoise < 1.0)
            {
                discard; // Discard the pixel if the noise is less than 1.0
            }

            // Edge detection for burn effect
            float outlineWidth = 0.01;
            float outlineStep1 = step(_Glossiness + outlineWidth, noise);
            float outlineStep2 = step(_Glossiness + 2 * outlineWidth, noise);
            
            // Blinking effect
            float blinkSpeed = 5.0;
            float blinkIntensity = 1;
            float blink = (sin(_Time.y * blinkSpeed) + 1.0) * 0.5 * blinkIntensity; // Calculate the blinking effect

            if (steppedNoise > outlineStep1 && steppedNoise > outlineStep2)
            {
                o.Albedo = orange; // Set the albedo to orange
                o.Emission = orange * blink; // Set the emission to orange multiplied by the blink effect
                o.Alpha = c.a * 0.9; // Set the alpha to 90% of the original alpha
            }
            else if (steppedNoise > outlineStep2)
            {
                o.Albedo = grey * c; // Set the albedo to grey multiplied by the original color
                o.Alpha = c.a; // Set the alpha to the original alpha
            }
            else
            {
                o.Albedo = c.rgb; // Set the albedo to the original color
                o.Emission = float3(0, 0, 0); // Set the emission to black
                o.Alpha = c.a; // Set the alpha to the original alpha
            }
            o.Smoothness = specGloss.r * _Glossiness; // Set the smoothness to the red channel of the specular glossiness map multiplied by the glossiness value
        }
        ENDCG
    }
    FallBack "Diffuse" // Fallback to diffuse shader if this shader fails
}
