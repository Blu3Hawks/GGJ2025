Shader "Clouds"
{
    Properties
    {
        Vector4_360d8b65a54c4edc973d5b8672747521("Rotate Projection", Vector) = (1, 0, 0, 0)
        Vector1_5309eb0587724507a4a28b2e28142721("Noise Scale", Float) = 10
        Vector1_f1d454e732f0402ea31e8133d808d0c6("Noise Speed", Float) = 0.1
        Vector1_39cf22e90d0a4705adfc4a829258bfc4("Noise Height", Float) = 1
        Vector4_27b1d812a8cc4cf88ddd8924e2033c08("Noise Remap", Vector) = (0, 1, -1, 1)
        Color_f81a3cb37ce142a7ac3275b394ac5e7d("Color Peak", Color) = (1, 1, 1, 0)
        Color_fe1e6e07311f428ebdd8052e06fcd91a("Color Valley", Color) = (0, 0, 0, 0)
        Vector1_49d18ef4f18f4021911a4191e8274c31("Noise Edge 1", Float) = 0
        Vector1_6a33acd3a5c24565b6acce2336e144c6("Noise Edge 2", Float) = 1
        Vector1_24842a2050e64299b6df635b2d3a8f28("Noise Power", Float) = 2
        Vector1_36f0f20eab054237af2a746e717296b9("Base Scale", Float) = 5
        Vector1_b4db6c3af56842a887c0698bd5c0367b("Base Speed", Float) = 0
        Vector1_31fa79eca53a447998750bbf42505f35("Base Strength", Float) = 0
        Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c("Emission Strength", Float) = 2
        Vector1_ce4edbf3031d4a90813460f0afb0821e("Curvature Raduis", Float) = 0
        Vector1_dff6fddf0f4e4d50992356f10c9046d9("Frensel Power", Float) = 1
        Vector1_f324948820054385ba7be41b09087e58("Frensel Opacity", Float) = 1
        Vector1_a8a3a6f7b021486a8b2ff31e6d41a020("Fade Depth", Float) = 1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite on

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_360d8b65a54c4edc973d5b8672747521;
        float Vector1_5309eb0587724507a4a28b2e28142721;
        float Vector1_f1d454e732f0402ea31e8133d808d0c6;
        float Vector1_39cf22e90d0a4705adfc4a829258bfc4;
        float4 Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
        float4 Color_f81a3cb37ce142a7ac3275b394ac5e7d;
        float4 Color_fe1e6e07311f428ebdd8052e06fcd91a;
        float Vector1_49d18ef4f18f4021911a4191e8274c31;
        float Vector1_6a33acd3a5c24565b6acce2336e144c6;
        float Vector1_24842a2050e64299b6df635b2d3a8f28;
        float Vector1_36f0f20eab054237af2a746e717296b9;
        float Vector1_b4db6c3af56842a887c0698bd5c0367b;
        float Vector1_31fa79eca53a447998750bbf42505f35;
        float Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
        float Vector1_ce4edbf3031d4a90813460f0afb0821e;
        float Vector1_dff6fddf0f4e4d50992356f10c9046d9;
        float Vector1_f324948820054385ba7be41b09087e58;
        float Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2);
            float _Property_a42bd850ec8849ac873427716fcd52b6_Out_0 = Vector1_ce4edbf3031d4a90813460f0afb0821e;
            float _Divide_09789dab75464af9bf748d443ef948ed_Out_2;
            Unity_Divide_float(_Distance_5a70c41a70ca43ae887a828fba053a66_Out_2, _Property_a42bd850ec8849ac873427716fcd52b6_Out_0, _Divide_09789dab75464af9bf748d443ef948ed_Out_2);
            float _Power_05aebe4ca03441368a1c5c0562418c15_Out_2;
            Unity_Power_float(_Divide_09789dab75464af9bf748d443ef948ed_Out_2, 3, _Power_05aebe4ca03441368a1c5c0562418c15_Out_2);
            float3 _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2;
            Unity_Multiply_float(IN.TangentSpaceNormal, (_Power_05aebe4ca03441368a1c5c0562418c15_Out_2.xxx), _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2);
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float3 _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxx), _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2);
            float _Property_a1e860cd98cd4becb5558bee2180172b_Out_0 = Vector1_39cf22e90d0a4705adfc4a829258bfc4;
            float3 _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2;
            Unity_Multiply_float(_Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2, (_Property_a1e860cd98cd4becb5558bee2180172b_Out_0.xxx), _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2);
            float3 _Add_43411ff224114ff0a121e4901eae0ee9_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2);
            float3 _Add_c52d45167416479ba160c91915e84f96_Out_2;
            Unity_Add_float3(_Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2, _Add_c52d45167416479ba160c91915e84f96_Out_2);
            description.Position = _Add_c52d45167416479ba160c91915e84f96_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_52df469bf397479bb9416ae5ed1fdb1d_Out_0 = Color_fe1e6e07311f428ebdd8052e06fcd91a;
            float4 _Property_39dc7f2d5fb14503821f4e269ae9935e_Out_0 = Color_f81a3cb37ce142a7ac3275b394ac5e7d;
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float4 _Lerp_ecd21a4c45bd4b5b871ca1875f924fa2_Out_3;
            Unity_Lerp_float4(_Property_52df469bf397479bb9416ae5ed1fdb1d_Out_0, _Property_39dc7f2d5fb14503821f4e269ae9935e_Out_0, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxxx), _Lerp_ecd21a4c45bd4b5b871ca1875f924fa2_Out_3);
            float _Property_30c28f8ee0624dea856c61b1d023063b_Out_0 = Vector1_dff6fddf0f4e4d50992356f10c9046d9;
            float _FresnelEffect_b3f445de6232445a8fa639165a3cd6b5_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_30c28f8ee0624dea856c61b1d023063b_Out_0, _FresnelEffect_b3f445de6232445a8fa639165a3cd6b5_Out_3);
            float _Multiply_2a36b6a83f804961868669a03ba8fc69_Out_2;
            Unity_Multiply_float(_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2, _FresnelEffect_b3f445de6232445a8fa639165a3cd6b5_Out_3, _Multiply_2a36b6a83f804961868669a03ba8fc69_Out_2);
            float _Property_4a7179a3f9d04947b9a9c97f7343ecee_Out_0 = Vector1_f324948820054385ba7be41b09087e58;
            float _Multiply_5b23692792a648ad81d6d6ae70fdeb8d_Out_2;
            Unity_Multiply_float(_Multiply_2a36b6a83f804961868669a03ba8fc69_Out_2, _Property_4a7179a3f9d04947b9a9c97f7343ecee_Out_0, _Multiply_5b23692792a648ad81d6d6ae70fdeb8d_Out_2);
            float4 _Add_6b4cb75f2c694871821ae31671c44adb_Out_2;
            Unity_Add_float4(_Lerp_ecd21a4c45bd4b5b871ca1875f924fa2_Out_3, (_Multiply_5b23692792a648ad81d6d6ae70fdeb8d_Out_2.xxxx), _Add_6b4cb75f2c694871821ae31671c44adb_Out_2);
            float _Property_077cec548db048408fb4949776a2b1dd_Out_0 = Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
            float4 _Multiply_c2e1aba60b9749eaa3fe421a21161d5d_Out_2;
            Unity_Multiply_float(_Add_6b4cb75f2c694871821ae31671c44adb_Out_2, (_Property_077cec548db048408fb4949776a2b1dd_Out_0.xxxx), _Multiply_c2e1aba60b9749eaa3fe421a21161d5d_Out_2);
            float _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1);
            float4 _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0 = IN.ScreenPosition;
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_R_1 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[0];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_G_2 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[1];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_B_3 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[2];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[3];
            float _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2;
            Unity_Subtract_float(_Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4, 1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2);
            float _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2;
            Unity_Subtract_float(_SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2, _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2);
            float _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0 = Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
            float _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2;
            Unity_Divide_float(_Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2, _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0, _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2);
            float _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            Unity_Saturate_float(_Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2, _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1);
            surface.BaseColor = (_Multiply_c2e1aba60b9749eaa3fe421a21161d5d_Out_2.xyz);
            surface.Alpha = _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_360d8b65a54c4edc973d5b8672747521;
        float Vector1_5309eb0587724507a4a28b2e28142721;
        float Vector1_f1d454e732f0402ea31e8133d808d0c6;
        float Vector1_39cf22e90d0a4705adfc4a829258bfc4;
        float4 Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
        float4 Color_f81a3cb37ce142a7ac3275b394ac5e7d;
        float4 Color_fe1e6e07311f428ebdd8052e06fcd91a;
        float Vector1_49d18ef4f18f4021911a4191e8274c31;
        float Vector1_6a33acd3a5c24565b6acce2336e144c6;
        float Vector1_24842a2050e64299b6df635b2d3a8f28;
        float Vector1_36f0f20eab054237af2a746e717296b9;
        float Vector1_b4db6c3af56842a887c0698bd5c0367b;
        float Vector1_31fa79eca53a447998750bbf42505f35;
        float Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
        float Vector1_ce4edbf3031d4a90813460f0afb0821e;
        float Vector1_dff6fddf0f4e4d50992356f10c9046d9;
        float Vector1_f324948820054385ba7be41b09087e58;
        float Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2);
            float _Property_a42bd850ec8849ac873427716fcd52b6_Out_0 = Vector1_ce4edbf3031d4a90813460f0afb0821e;
            float _Divide_09789dab75464af9bf748d443ef948ed_Out_2;
            Unity_Divide_float(_Distance_5a70c41a70ca43ae887a828fba053a66_Out_2, _Property_a42bd850ec8849ac873427716fcd52b6_Out_0, _Divide_09789dab75464af9bf748d443ef948ed_Out_2);
            float _Power_05aebe4ca03441368a1c5c0562418c15_Out_2;
            Unity_Power_float(_Divide_09789dab75464af9bf748d443ef948ed_Out_2, 3, _Power_05aebe4ca03441368a1c5c0562418c15_Out_2);
            float3 _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2;
            Unity_Multiply_float(IN.TangentSpaceNormal, (_Power_05aebe4ca03441368a1c5c0562418c15_Out_2.xxx), _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2);
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float3 _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxx), _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2);
            float _Property_a1e860cd98cd4becb5558bee2180172b_Out_0 = Vector1_39cf22e90d0a4705adfc4a829258bfc4;
            float3 _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2;
            Unity_Multiply_float(_Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2, (_Property_a1e860cd98cd4becb5558bee2180172b_Out_0.xxx), _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2);
            float3 _Add_43411ff224114ff0a121e4901eae0ee9_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2);
            float3 _Add_c52d45167416479ba160c91915e84f96_Out_2;
            Unity_Add_float3(_Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2, _Add_c52d45167416479ba160c91915e84f96_Out_2);
            description.Position = _Add_c52d45167416479ba160c91915e84f96_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1);
            float4 _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0 = IN.ScreenPosition;
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_R_1 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[0];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_G_2 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[1];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_B_3 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[2];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[3];
            float _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2;
            Unity_Subtract_float(_Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4, 1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2);
            float _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2;
            Unity_Subtract_float(_SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2, _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2);
            float _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0 = Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
            float _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2;
            Unity_Divide_float(_Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2, _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0, _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2);
            float _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            Unity_Saturate_float(_Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2, _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1);
            surface.Alpha = _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_360d8b65a54c4edc973d5b8672747521;
        float Vector1_5309eb0587724507a4a28b2e28142721;
        float Vector1_f1d454e732f0402ea31e8133d808d0c6;
        float Vector1_39cf22e90d0a4705adfc4a829258bfc4;
        float4 Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
        float4 Color_f81a3cb37ce142a7ac3275b394ac5e7d;
        float4 Color_fe1e6e07311f428ebdd8052e06fcd91a;
        float Vector1_49d18ef4f18f4021911a4191e8274c31;
        float Vector1_6a33acd3a5c24565b6acce2336e144c6;
        float Vector1_24842a2050e64299b6df635b2d3a8f28;
        float Vector1_36f0f20eab054237af2a746e717296b9;
        float Vector1_b4db6c3af56842a887c0698bd5c0367b;
        float Vector1_31fa79eca53a447998750bbf42505f35;
        float Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
        float Vector1_ce4edbf3031d4a90813460f0afb0821e;
        float Vector1_dff6fddf0f4e4d50992356f10c9046d9;
        float Vector1_f324948820054385ba7be41b09087e58;
        float Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2);
            float _Property_a42bd850ec8849ac873427716fcd52b6_Out_0 = Vector1_ce4edbf3031d4a90813460f0afb0821e;
            float _Divide_09789dab75464af9bf748d443ef948ed_Out_2;
            Unity_Divide_float(_Distance_5a70c41a70ca43ae887a828fba053a66_Out_2, _Property_a42bd850ec8849ac873427716fcd52b6_Out_0, _Divide_09789dab75464af9bf748d443ef948ed_Out_2);
            float _Power_05aebe4ca03441368a1c5c0562418c15_Out_2;
            Unity_Power_float(_Divide_09789dab75464af9bf748d443ef948ed_Out_2, 3, _Power_05aebe4ca03441368a1c5c0562418c15_Out_2);
            float3 _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2;
            Unity_Multiply_float(IN.TangentSpaceNormal, (_Power_05aebe4ca03441368a1c5c0562418c15_Out_2.xxx), _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2);
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float3 _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxx), _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2);
            float _Property_a1e860cd98cd4becb5558bee2180172b_Out_0 = Vector1_39cf22e90d0a4705adfc4a829258bfc4;
            float3 _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2;
            Unity_Multiply_float(_Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2, (_Property_a1e860cd98cd4becb5558bee2180172b_Out_0.xxx), _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2);
            float3 _Add_43411ff224114ff0a121e4901eae0ee9_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2);
            float3 _Add_c52d45167416479ba160c91915e84f96_Out_2;
            Unity_Add_float3(_Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2, _Add_c52d45167416479ba160c91915e84f96_Out_2);
            description.Position = _Add_c52d45167416479ba160c91915e84f96_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1);
            float4 _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0 = IN.ScreenPosition;
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_R_1 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[0];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_G_2 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[1];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_B_3 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[2];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[3];
            float _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2;
            Unity_Subtract_float(_Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4, 1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2);
            float _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2;
            Unity_Subtract_float(_SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2, _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2);
            float _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0 = Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
            float _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2;
            Unity_Divide_float(_Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2, _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0, _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2);
            float _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            Unity_Saturate_float(_Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2, _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1);
            surface.Alpha = _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_360d8b65a54c4edc973d5b8672747521;
        float Vector1_5309eb0587724507a4a28b2e28142721;
        float Vector1_f1d454e732f0402ea31e8133d808d0c6;
        float Vector1_39cf22e90d0a4705adfc4a829258bfc4;
        float4 Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
        float4 Color_f81a3cb37ce142a7ac3275b394ac5e7d;
        float4 Color_fe1e6e07311f428ebdd8052e06fcd91a;
        float Vector1_49d18ef4f18f4021911a4191e8274c31;
        float Vector1_6a33acd3a5c24565b6acce2336e144c6;
        float Vector1_24842a2050e64299b6df635b2d3a8f28;
        float Vector1_36f0f20eab054237af2a746e717296b9;
        float Vector1_b4db6c3af56842a887c0698bd5c0367b;
        float Vector1_31fa79eca53a447998750bbf42505f35;
        float Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
        float Vector1_ce4edbf3031d4a90813460f0afb0821e;
        float Vector1_dff6fddf0f4e4d50992356f10c9046d9;
        float Vector1_f324948820054385ba7be41b09087e58;
        float Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2);
            float _Property_a42bd850ec8849ac873427716fcd52b6_Out_0 = Vector1_ce4edbf3031d4a90813460f0afb0821e;
            float _Divide_09789dab75464af9bf748d443ef948ed_Out_2;
            Unity_Divide_float(_Distance_5a70c41a70ca43ae887a828fba053a66_Out_2, _Property_a42bd850ec8849ac873427716fcd52b6_Out_0, _Divide_09789dab75464af9bf748d443ef948ed_Out_2);
            float _Power_05aebe4ca03441368a1c5c0562418c15_Out_2;
            Unity_Power_float(_Divide_09789dab75464af9bf748d443ef948ed_Out_2, 3, _Power_05aebe4ca03441368a1c5c0562418c15_Out_2);
            float3 _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2;
            Unity_Multiply_float(IN.TangentSpaceNormal, (_Power_05aebe4ca03441368a1c5c0562418c15_Out_2.xxx), _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2);
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float3 _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxx), _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2);
            float _Property_a1e860cd98cd4becb5558bee2180172b_Out_0 = Vector1_39cf22e90d0a4705adfc4a829258bfc4;
            float3 _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2;
            Unity_Multiply_float(_Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2, (_Property_a1e860cd98cd4becb5558bee2180172b_Out_0.xxx), _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2);
            float3 _Add_43411ff224114ff0a121e4901eae0ee9_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2);
            float3 _Add_c52d45167416479ba160c91915e84f96_Out_2;
            Unity_Add_float3(_Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2, _Add_c52d45167416479ba160c91915e84f96_Out_2);
            description.Position = _Add_c52d45167416479ba160c91915e84f96_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_52df469bf397479bb9416ae5ed1fdb1d_Out_0 = Color_fe1e6e07311f428ebdd8052e06fcd91a;
            float4 _Property_39dc7f2d5fb14503821f4e269ae9935e_Out_0 = Color_f81a3cb37ce142a7ac3275b394ac5e7d;
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float4 _Lerp_ecd21a4c45bd4b5b871ca1875f924fa2_Out_3;
            Unity_Lerp_float4(_Property_52df469bf397479bb9416ae5ed1fdb1d_Out_0, _Property_39dc7f2d5fb14503821f4e269ae9935e_Out_0, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxxx), _Lerp_ecd21a4c45bd4b5b871ca1875f924fa2_Out_3);
            float _Property_30c28f8ee0624dea856c61b1d023063b_Out_0 = Vector1_dff6fddf0f4e4d50992356f10c9046d9;
            float _FresnelEffect_b3f445de6232445a8fa639165a3cd6b5_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_30c28f8ee0624dea856c61b1d023063b_Out_0, _FresnelEffect_b3f445de6232445a8fa639165a3cd6b5_Out_3);
            float _Multiply_2a36b6a83f804961868669a03ba8fc69_Out_2;
            Unity_Multiply_float(_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2, _FresnelEffect_b3f445de6232445a8fa639165a3cd6b5_Out_3, _Multiply_2a36b6a83f804961868669a03ba8fc69_Out_2);
            float _Property_4a7179a3f9d04947b9a9c97f7343ecee_Out_0 = Vector1_f324948820054385ba7be41b09087e58;
            float _Multiply_5b23692792a648ad81d6d6ae70fdeb8d_Out_2;
            Unity_Multiply_float(_Multiply_2a36b6a83f804961868669a03ba8fc69_Out_2, _Property_4a7179a3f9d04947b9a9c97f7343ecee_Out_0, _Multiply_5b23692792a648ad81d6d6ae70fdeb8d_Out_2);
            float4 _Add_6b4cb75f2c694871821ae31671c44adb_Out_2;
            Unity_Add_float4(_Lerp_ecd21a4c45bd4b5b871ca1875f924fa2_Out_3, (_Multiply_5b23692792a648ad81d6d6ae70fdeb8d_Out_2.xxxx), _Add_6b4cb75f2c694871821ae31671c44adb_Out_2);
            float _Property_077cec548db048408fb4949776a2b1dd_Out_0 = Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
            float4 _Multiply_c2e1aba60b9749eaa3fe421a21161d5d_Out_2;
            Unity_Multiply_float(_Add_6b4cb75f2c694871821ae31671c44adb_Out_2, (_Property_077cec548db048408fb4949776a2b1dd_Out_0.xxxx), _Multiply_c2e1aba60b9749eaa3fe421a21161d5d_Out_2);
            float _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1);
            float4 _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0 = IN.ScreenPosition;
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_R_1 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[0];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_G_2 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[1];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_B_3 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[2];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[3];
            float _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2;
            Unity_Subtract_float(_Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4, 1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2);
            float _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2;
            Unity_Subtract_float(_SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2, _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2);
            float _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0 = Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
            float _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2;
            Unity_Divide_float(_Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2, _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0, _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2);
            float _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            Unity_Saturate_float(_Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2, _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1);
            surface.BaseColor = (_Multiply_c2e1aba60b9749eaa3fe421a21161d5d_Out_2.xyz);
            surface.Alpha = _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_360d8b65a54c4edc973d5b8672747521;
        float Vector1_5309eb0587724507a4a28b2e28142721;
        float Vector1_f1d454e732f0402ea31e8133d808d0c6;
        float Vector1_39cf22e90d0a4705adfc4a829258bfc4;
        float4 Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
        float4 Color_f81a3cb37ce142a7ac3275b394ac5e7d;
        float4 Color_fe1e6e07311f428ebdd8052e06fcd91a;
        float Vector1_49d18ef4f18f4021911a4191e8274c31;
        float Vector1_6a33acd3a5c24565b6acce2336e144c6;
        float Vector1_24842a2050e64299b6df635b2d3a8f28;
        float Vector1_36f0f20eab054237af2a746e717296b9;
        float Vector1_b4db6c3af56842a887c0698bd5c0367b;
        float Vector1_31fa79eca53a447998750bbf42505f35;
        float Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
        float Vector1_ce4edbf3031d4a90813460f0afb0821e;
        float Vector1_dff6fddf0f4e4d50992356f10c9046d9;
        float Vector1_f324948820054385ba7be41b09087e58;
        float Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2);
            float _Property_a42bd850ec8849ac873427716fcd52b6_Out_0 = Vector1_ce4edbf3031d4a90813460f0afb0821e;
            float _Divide_09789dab75464af9bf748d443ef948ed_Out_2;
            Unity_Divide_float(_Distance_5a70c41a70ca43ae887a828fba053a66_Out_2, _Property_a42bd850ec8849ac873427716fcd52b6_Out_0, _Divide_09789dab75464af9bf748d443ef948ed_Out_2);
            float _Power_05aebe4ca03441368a1c5c0562418c15_Out_2;
            Unity_Power_float(_Divide_09789dab75464af9bf748d443ef948ed_Out_2, 3, _Power_05aebe4ca03441368a1c5c0562418c15_Out_2);
            float3 _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2;
            Unity_Multiply_float(IN.TangentSpaceNormal, (_Power_05aebe4ca03441368a1c5c0562418c15_Out_2.xxx), _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2);
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float3 _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxx), _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2);
            float _Property_a1e860cd98cd4becb5558bee2180172b_Out_0 = Vector1_39cf22e90d0a4705adfc4a829258bfc4;
            float3 _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2;
            Unity_Multiply_float(_Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2, (_Property_a1e860cd98cd4becb5558bee2180172b_Out_0.xxx), _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2);
            float3 _Add_43411ff224114ff0a121e4901eae0ee9_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2);
            float3 _Add_c52d45167416479ba160c91915e84f96_Out_2;
            Unity_Add_float3(_Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2, _Add_c52d45167416479ba160c91915e84f96_Out_2);
            description.Position = _Add_c52d45167416479ba160c91915e84f96_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1);
            float4 _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0 = IN.ScreenPosition;
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_R_1 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[0];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_G_2 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[1];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_B_3 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[2];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[3];
            float _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2;
            Unity_Subtract_float(_Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4, 1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2);
            float _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2;
            Unity_Subtract_float(_SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2, _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2);
            float _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0 = Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
            float _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2;
            Unity_Divide_float(_Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2, _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0, _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2);
            float _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            Unity_Saturate_float(_Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2, _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1);
            surface.Alpha = _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Vector4_360d8b65a54c4edc973d5b8672747521;
        float Vector1_5309eb0587724507a4a28b2e28142721;
        float Vector1_f1d454e732f0402ea31e8133d808d0c6;
        float Vector1_39cf22e90d0a4705adfc4a829258bfc4;
        float4 Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
        float4 Color_f81a3cb37ce142a7ac3275b394ac5e7d;
        float4 Color_fe1e6e07311f428ebdd8052e06fcd91a;
        float Vector1_49d18ef4f18f4021911a4191e8274c31;
        float Vector1_6a33acd3a5c24565b6acce2336e144c6;
        float Vector1_24842a2050e64299b6df635b2d3a8f28;
        float Vector1_36f0f20eab054237af2a746e717296b9;
        float Vector1_b4db6c3af56842a887c0698bd5c0367b;
        float Vector1_31fa79eca53a447998750bbf42505f35;
        float Vector1_dd6bbb4185af4e92beaf75cf4e3cbc1c;
        float Vector1_ce4edbf3031d4a90813460f0afb0821e;
        float Vector1_dff6fddf0f4e4d50992356f10c9046d9;
        float Vector1_f324948820054385ba7be41b09087e58;
        float Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5a70c41a70ca43ae887a828fba053a66_Out_2);
            float _Property_a42bd850ec8849ac873427716fcd52b6_Out_0 = Vector1_ce4edbf3031d4a90813460f0afb0821e;
            float _Divide_09789dab75464af9bf748d443ef948ed_Out_2;
            Unity_Divide_float(_Distance_5a70c41a70ca43ae887a828fba053a66_Out_2, _Property_a42bd850ec8849ac873427716fcd52b6_Out_0, _Divide_09789dab75464af9bf748d443ef948ed_Out_2);
            float _Power_05aebe4ca03441368a1c5c0562418c15_Out_2;
            Unity_Power_float(_Divide_09789dab75464af9bf748d443ef948ed_Out_2, 3, _Power_05aebe4ca03441368a1c5c0562418c15_Out_2);
            float3 _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2;
            Unity_Multiply_float(IN.TangentSpaceNormal, (_Power_05aebe4ca03441368a1c5c0562418c15_Out_2.xxx), _Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2);
            float _Property_4b800ed154634365ad85ab71dc5234e6_Out_0 = Vector1_49d18ef4f18f4021911a4191e8274c31;
            float _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0 = Vector1_6a33acd3a5c24565b6acce2336e144c6;
            float4 _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0 = Vector4_360d8b65a54c4edc973d5b8672747521;
            float _Split_755dad5258a8443796f253f2baebff25_R_1 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[0];
            float _Split_755dad5258a8443796f253f2baebff25_G_2 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[1];
            float _Split_755dad5258a8443796f253f2baebff25_B_3 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[2];
            float _Split_755dad5258a8443796f253f2baebff25_A_4 = _Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0[3];
            float3 _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_b0bc5693f1394dcfb519ae0a6ee6369c_Out_0.xyz), _Split_755dad5258a8443796f253f2baebff25_A_4, _RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3);
            float _Property_ae36a9215548454293e4932876e5f883_Out_0 = Vector1_f1d454e732f0402ea31e8133d808d0c6;
            float _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_ae36a9215548454293e4932876e5f883_Out_0, _Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2);
            float2 _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_e4b5076b00fc4a778b8b2543b48d242d_Out_2.xx), _TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3);
            float _Property_28cf35a3cc254af19622c19a1336d9da_Out_0 = Vector1_5309eb0587724507a4a28b2e28142721;
            float _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_7cbb124c72194caeb32d227a1f284e9c_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2);
            float2 _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3);
            float _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c1e355abe7b245bb82bfe8fed4a6d83a_Out_3, _Property_28cf35a3cc254af19622c19a1336d9da_Out_0, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2);
            float _Add_a43ae1d30835449ea17ab200fe15095e_Out_2;
            Unity_Add_float(_GradientNoise_a83fcedce91345249847d1668017ebb6_Out_2, _GradientNoise_9f1c77dfcd8f45c2988742ef658d50f1_Out_2, _Add_a43ae1d30835449ea17ab200fe15095e_Out_2);
            float _Divide_b08a69347da94cd49c47666b12028ecb_Out_2;
            Unity_Divide_float(_Add_a43ae1d30835449ea17ab200fe15095e_Out_2, 2, _Divide_b08a69347da94cd49c47666b12028ecb_Out_2);
            float _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1;
            Unity_Saturate_float(_Divide_b08a69347da94cd49c47666b12028ecb_Out_2, _Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1);
            float _Property_f52e066645234c01a401373476f88119_Out_0 = Vector1_24842a2050e64299b6df635b2d3a8f28;
            float _Power_49f9207828834973a33b7d7576a6f4ef_Out_2;
            Unity_Power_float(_Saturate_4315a7aafafa4b5388a61a83181fea3e_Out_1, _Property_f52e066645234c01a401373476f88119_Out_0, _Power_49f9207828834973a33b7d7576a6f4ef_Out_2);
            float4 _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0 = Vector4_27b1d812a8cc4cf88ddd8924e2033c08;
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[0];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[1];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[2];
            float _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4 = _Property_7212bfa19d5c43a1ba2188ae5b84d5a6_Out_0[3];
            float4 _Combine_56426f72964e4098ad22a98723be709c_RGBA_4;
            float3 _Combine_56426f72964e4098ad22a98723be709c_RGB_5;
            float2 _Combine_56426f72964e4098ad22a98723be709c_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_R_1, _Split_d14b14bb9d2942b4892a0d80d7b7332a_G_2, 0, 0, _Combine_56426f72964e4098ad22a98723be709c_RGBA_4, _Combine_56426f72964e4098ad22a98723be709c_RGB_5, _Combine_56426f72964e4098ad22a98723be709c_RG_6);
            float4 _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4;
            float3 _Combine_e35b010136844a49bed84338d61c1a04_RGB_5;
            float2 _Combine_e35b010136844a49bed84338d61c1a04_RG_6;
            Unity_Combine_float(_Split_d14b14bb9d2942b4892a0d80d7b7332a_B_3, _Split_d14b14bb9d2942b4892a0d80d7b7332a_A_4, 0, 0, _Combine_e35b010136844a49bed84338d61c1a04_RGBA_4, _Combine_e35b010136844a49bed84338d61c1a04_RGB_5, _Combine_e35b010136844a49bed84338d61c1a04_RG_6);
            float _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3;
            Unity_Remap_float(_Power_49f9207828834973a33b7d7576a6f4ef_Out_2, _Combine_56426f72964e4098ad22a98723be709c_RG_6, _Combine_e35b010136844a49bed84338d61c1a04_RG_6, _Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3);
            float _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1;
            Unity_Absolute_float(_Remap_2ff49261658f4dbaabc0677cb1ca9199_Out_3, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1);
            float _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3;
            Unity_Smoothstep_float(_Property_4b800ed154634365ad85ab71dc5234e6_Out_0, _Property_f03d2e5a725a4e2798e4366dbb03989c_Out_0, _Absolute_9d171770e7464072b4efef7d8d53bbaf_Out_1, _Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3);
            float _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0 = Vector1_b4db6c3af56842a887c0698bd5c0367b;
            float _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_2aeb8261e1144d9390e276c5d99f8fb6_Out_0, _Multiply_26974279afea4ee4a46181910c11d8d8_Out_2);
            float2 _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_bb8771ea35ba4cda89fb970c8fc6e2ec_Out_3.xy), float2 (1, 1), (_Multiply_26974279afea4ee4a46181910c11d8d8_Out_2.xx), _TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3);
            float _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0 = Vector1_36f0f20eab054237af2a746e717296b9;
            float _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_cde19da58d9e4d138199a94a1e427b28_Out_3, _Property_14caea732f0e419fb286e2cbf638b0d6_Out_0, _GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2);
            float _Property_4c00694c0f864f1f993f277bd777b48a_Out_0 = Vector1_31fa79eca53a447998750bbf42505f35;
            float _Multiply_831677fbd758449ab222d4970881ccaf_Out_2;
            Unity_Multiply_float(_GradientNoise_f7d82daaeb7d4080b569e658ae6b4d0d_Out_2, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2);
            float _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2;
            Unity_Add_float(_Smoothstep_cee457a30bc34f4a97233af5aa59824d_Out_3, _Multiply_831677fbd758449ab222d4970881ccaf_Out_2, _Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2);
            float _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2;
            Unity_Add_float(1, _Property_4c00694c0f864f1f993f277bd777b48a_Out_0, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2);
            float _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2;
            Unity_Divide_float(_Add_14bede1a75d04f9eb3e70e662c5f9b2b_Out_2, _Add_f6fe42e1add040bf9e2c31ad1bb48fd2_Out_2, _Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2);
            float3 _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_1e6e0d3e9d1a4f558f12f6b702a16451_Out_2.xxx), _Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2);
            float _Property_a1e860cd98cd4becb5558bee2180172b_Out_0 = Vector1_39cf22e90d0a4705adfc4a829258bfc4;
            float3 _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2;
            Unity_Multiply_float(_Multiply_d59354b7bca040a4aa5aeef31bc17716_Out_2, (_Property_a1e860cd98cd4becb5558bee2180172b_Out_0.xxx), _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2);
            float3 _Add_43411ff224114ff0a121e4901eae0ee9_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_9c9e12dc0c0b4dcd83e2b75e3c901d11_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2);
            float3 _Add_c52d45167416479ba160c91915e84f96_Out_2;
            Unity_Add_float3(_Multiply_369b006195e14d899c5c5ac277f38ad8_Out_2, _Add_43411ff224114ff0a121e4901eae0ee9_Out_2, _Add_c52d45167416479ba160c91915e84f96_Out_2);
            description.Position = _Add_c52d45167416479ba160c91915e84f96_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1);
            float4 _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0 = IN.ScreenPosition;
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_R_1 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[0];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_G_2 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[1];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_B_3 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[2];
            float _Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4 = _ScreenPosition_87385e7385ec45a6b4a3ba154ca9057a_Out_0[3];
            float _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2;
            Unity_Subtract_float(_Split_30af5583aa5047e8a5dc66d1ab0f9b9e_A_4, 1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2);
            float _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2;
            Unity_Subtract_float(_SceneDepth_c981f34dc41d48c8a72df89c6d127747_Out_1, _Subtract_8b57bfb60c354bda96f67328c6cd812d_Out_2, _Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2);
            float _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0 = Vector1_a8a3a6f7b021486a8b2ff31e6d41a020;
            float _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2;
            Unity_Divide_float(_Subtract_f3096de6d1e44ae0ab317d61e1247f32_Out_2, _Property_7de0c4022d1e49a9a242733fc5842c80_Out_0, _Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2);
            float _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            Unity_Saturate_float(_Divide_8578cd9bbce84f8dbfe11c96bc16bb28_Out_2, _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1);
            surface.Alpha = _Saturate_9374822e04194ea9bf0de8ff2e67e19f_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}