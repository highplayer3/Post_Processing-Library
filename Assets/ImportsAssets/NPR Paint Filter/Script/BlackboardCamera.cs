using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class BlackboardCamera : MonoBehaviour
	{
		public bool m_Fullscreen = false;
		public string m_FxLayer = "TransparentFX";
		public Color m_EdgeColor = new Color (1, 1, 1, 1);
		public float m_EdgeThreshold = 0.07f;
		[Range(0f, 0.05f)] public float m_SampleDist = 0.007f;
		public float m_Hardness = 0.24f;
		public bool m_Invert = true;
		[Header("Internal")]
		public Shader m_SdrRtReplace;
		public Material m_Mat;
		Camera m_RtCam;
		Camera m_Cam;
		RenderTexture m_Rt1, m_Rt2;

		void OnEnable ()
		{
			Shader sdr = Shader.Find ("NPR Paint Filter/Blackboard");
			m_Mat = new Material (sdr);
			
			m_Rt1 = RenderTexture.GetTemporary (Screen.width, Screen.height, 16);
			m_Rt2 = RenderTexture.GetTemporary (Screen.width, Screen.height, 16);
			
			m_Cam = GetComponent<Camera> ();
			GameObject go = new GameObject();
			go.name = "RtCam";
			m_RtCam = go.AddComponent<Camera> ();
			m_RtCam.transform.parent = m_Cam.gameObject.transform;

			m_SdrRtReplace = Shader.Find ("NPR Paint Filter/Blackboard Color");
		}
		void OnDisable ()
		{
			if (m_Rt1)
			{
				RenderTexture.ReleaseTemporary (m_Rt1);
				m_Rt1 = null;
			}
			if (m_Rt2)
			{
				RenderTexture.ReleaseTemporary (m_Rt2);
				m_Rt2 = null;
			}
			if (m_Mat)
			{
				DestroyImmediate (m_Mat);
				m_Mat = null;
			}
		}
		void Update ()
		{
			m_RtCam.CopyFrom (m_Cam);
			m_RtCam.clearFlags = CameraClearFlags.Color;
			m_RtCam.backgroundColor = Color.black;
			m_RtCam.targetTexture = m_Rt1;
			m_RtCam.enabled = false;
			m_RtCam.cullingMask = 1 << LayerMask.NameToLayer (m_FxLayer);
			m_RtCam.RenderWithShader (m_SdrRtReplace, "");
			
			if (m_Invert)
			{
				m_Mat.EnableKeyword ("WHITE_BOARD_1");
				m_Mat.DisableKeyword ("WHITE_BOARD_2");
			}
			else
			{
				m_Mat.EnableKeyword ("WHITE_BOARD_2");
				m_Mat.DisableKeyword ("WHITE_BOARD_1");
			}
			m_Mat.SetColor ("_EdgeColor", m_EdgeColor);
			m_Mat.SetFloat ("_EdgeThreshold", m_EdgeThreshold);
			m_Mat.SetFloat ("_SampleDist", m_SampleDist);
			m_Mat.SetFloat ("_Hardness", m_Hardness);

			RenderTexture rt0 = RenderTexture.GetTemporary (m_Rt1.width, m_Rt1.height, 0);
			Graphics.Blit (m_Rt1, rt0, m_Mat, 0);
			Graphics.Blit (rt0, m_Rt2, m_Mat, 1);
			RenderTexture.ReleaseTemporary (rt0);
		}
		void OnRenderImage (RenderTexture src, RenderTexture dst)
		{
			if (m_Fullscreen)
				Graphics.Blit (m_Rt2, dst);
			else
				Graphics.Blit (src, dst);
		}
		public RenderTexture GetResult ()
		{
			return m_Rt2;
		}
	}
}
