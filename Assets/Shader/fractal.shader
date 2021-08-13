// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "custom/fractal"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)

        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255

        _ColorMask("Color Mask", Float) = 15

       _param("(x,y):center z scale", Vector) = (0, 0, 1, 0)
       _julia("julia set", Vector) = (0, 0, 0, 0)
       _size("(width,height)", Vector) = (750, 1334, 0, 0)

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
    }

        SubShader
        {
            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
                "CanUseSpriteAtlas" = "True"
            }

            Stencil
            {
                Ref[_Stencil]
                Comp[_StencilComp]
                Pass[_StencilOp]
                ReadMask[_StencilReadMask]
                WriteMask[_StencilWriteMask]
            }

            Cull Off
            Lighting Off
            ZWrite Off
            ZTest[unity_GUIZTestMode]
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask[_ColorMask]

            Pass
            {
                Name "Default"
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0

                #include "UnityCG.cginc"
                #include "UnityUI.cginc"

                #pragma multi_compile __ UNITY_UI_CLIP_RECT
                #pragma multi_compile __ UNITY_UI_ALPHACLIP

                struct appdata_t
                {
                    float4 vertex   : POSITION;
                    float4 color    : COLOR;
                    float2 texcoord : TEXCOORD0;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f
                {
                    float4 vertex   : SV_POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord  : TEXCOORD0;
                    float4 worldPosition : TEXCOORD1;
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                sampler2D _MainTex;
                fixed4 _Color;
                fixed4 _TextureSampleAdd;
                float4 _ClipRect;
                float4 _MainTex_ST;
                float4 _param;
                float4 _julia;
                float4 _size;

                v2f vert(appdata_t v)
                {
                    v2f OUT;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                    OUT.worldPosition = v.vertex;
                    OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                    OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                    OUT.color = v.color * _Color;
                    return OUT;
                }

                float N(float2 z)
                {
                    return sqrt(z.x * z.x + z.y * z.y);
                    //return abs(z.x) + abs(z.y);
                }

                float2 calc(float2 z, float2 coord)
                {
                    return float2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) +coord;
                }

                fixed4 frag(v2f IN) : SV_Target
                {
                    //float2 coord = _size.xy * IN.texcoord;
                    //float2 center = _size.xy * 0.5;
                    //coord = abs(coord - center);
                    float2 coord = _size.xy * (IN.texcoord-0.5);
                    coord = coord / _size.y;
                    coord = coord * 1 / _param.z;

                    coord -= _param.xy;

                    

                    float2 init = _julia.xy;
                    float2 c = coord;
                    int repeat = 0;
                    for (int i = 0; i < 40; i++)
                    {
                        repeat++;
                        init = calc(init, c);
                        if (N(init) > 2)
                        {
                            break;
                        }
                    }

                    half4 color = half4(0, 0, 0, 1);
                    half2 texNew = half2(1-repeat / 20.0, 0.5);

                    color = tex2D(_MainTex, texNew)*IN.color;// 1 - repeat / 20.0;
                    color.a = IN.color.a;

                    return color;
                    
                }
            ENDCG
            }
        }
}
