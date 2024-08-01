Shader "Hidden/Ending-Spotlight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // Main texture
        _CenterX ("Center X", Range(0.0, 0.5)) = 0.25 // Center X position
        _CenterY ("Center Y", Range(0.0, 0.5)) = 0.25 // Center Y position
        _Radius ("Radius", Range(0.0, 0.5)) = 0.5 // Radius of the effect
        _Sharpness ("Sharpness", Range(0, 2)) = 2 // Sharpness of the effect
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img // Vertex shader
            #pragma fragment frag // Fragment shader

            #include "UnityCG.cginc" // Include common shader library

            sampler2D _MainTex; // Main texture
            float _CenterX, _CenterY; // Center positions
            float _Radius; // Radius of the effect
            float _Sharpness; // Sharpness of the effect

            // Fragment shader
            fixed4 frag (v2f_img i) : SV_Target
            {
                // Calculate the distance from the center
                float2 center = float2(_CenterX, _CenterY);
                float dist = distance(center, ComputeScreenPos(i.pos).xy / _ScreenParams.xy);

                // Sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // Apply the effect based on the distance, radius, and sharpness
                float effect = 1 - pow(dist / _Radius, _Sharpness);
                return col * effect;
            }
            ENDCG
        }
    }
}