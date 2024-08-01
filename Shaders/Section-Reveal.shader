Shader "Unlit/Section-Reveal" 
{
    Properties {
        _MainTex ("Outside Texture", 2D) = "white" {}
        _Color2 ("Section color", Color) = (1.0, 1.0, 1.0, 1.0)
        _EdgeWidth ("Edge width", Range(0.9, 0.1)) = 0.9
        _Val ("Height value", float) = 0
    }
 
    SubShader {
        Tags { "Queue"="Geometry" }
 
        //  PASS 1
        CGPROGRAM
        #pragma surface surf Standard
        // Define the input structure
        struct Input {
            float3 worldPos;
            float2 uv_MainTex;
        };
 
        sampler2D _MainTex;
        float _Val;
 
        // Surface shader function
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Discard the pixel if the world position is greater than the threshold
            if(IN.worldPos.y > _Val)
                discard;
            // Sample the texture
            fixed4 texColor = tex2D(_MainTex, IN.uv_MainTex);
            // Set the albedo color
            o.Albedo = texColor.rgb;
        }
 
        ENDCG

        //  PASS 2
        Pass {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 _Color2;
            float _Val;

            fixed4 frag(v2f i) : SV_Target {
                if(i.worldPos.y > _Val)
                    discard;

                return _Color2;
            }

            ENDCG
        }

        //  PASS 3
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            float _EdgeWidth;

            v2f vert(appdata_base v)
            {
                v2f o;
                v.vertex.xyz *= _EdgeWidth;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 _Color2;
            float _Val;

            fixed4 frag(v2f i) : SV_Target {
                if(i.worldPos.y > _Val)
                    discard;

                return _Color2;
            }

            ENDCG
        }

        //  PASS 4
        Cull Front

        CGPROGRAM
        #pragma surface surf Standard vertex:vert
        struct Input {
            float3 worldPos;
        };

        float _EdgeWidth;

        void vert(inout appdata_base v)
        {
            v.vertex.xyz *= _EdgeWidth;
        }

        fixed4 _Color1;
        float _Val;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            if(IN.worldPos.y > _Val)
                discard;

            o.Albedo = _Color1;
        }

        ENDCG
    }
}