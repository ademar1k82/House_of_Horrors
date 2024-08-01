Shader "Unlit/Geometry/Geometry-Triangles"
{
    // Define shader properties
    Properties
    {
        // Define a color property with default value of white
        _Color("Color", Color) = (1,1,1,1)
        // Define a 2D texture property with default value of white
        _MainTex("Albedo", 2D) = "white" {}
    }
   
    // Define a subshader
    SubShader
    {
        // Set the rendering queue, render type, and light mode
        Tags{ "Queue"="Geometry" "RenderType"= "Opaque" "LightMode" = "ForwardBase" }

        // Define a pass
        Pass
        {
            // Start a CG program
            CGPROGRAM

            // Include common CG code
            #include "UnityCG.cginc"
            // Specify the vertex, geometry, and fragment shaders
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            // Define shader variables
            float4 _Color;
            sampler2D _MainTex;

            // Define a structure for vertex to geometry shader
            struct v2g
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 vertex : TEXCOORD1;
            };

            // Define a structure for geometry to fragment shader
            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float light : TEXCOORD1;
            };

            // Vertex shader
            v2g vert(appdata_full v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            // Geometry shader
            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
            {
                g2f o;

                // Compute the normal
                float3 vecA = IN[1].vertex - IN[0].vertex;
                float3 vecB = IN[2].vertex - IN[0].vertex;
                float3 normal = cross(vecA, vecB);
                normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

                // Compute diffuse light
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.light = max(0., dot(normal, lightDir));

                // Compute barycentric uv
                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                // Append vertices to the triangle stream
                for(int i = 0; i < 3; i++)
                {
                    o.pos = IN[i].pos;
                    triStream.Append(o);
                }
            }

            // Fragment shader
            half4 frag(g2f i) : COLOR
            {
                // Sample the texture at the interpolated UV coordinates
                float4 col = tex2D(_MainTex, i.uv);
                // Multiply the color by the light intensity and the color property
                col.rgb *= i.light * _Color;
                return col;
            }

            // End the CG program
            ENDCG
        }
    }
    // Specify a fallback shader in case this shader fails
    Fallback "Diffuse"
}