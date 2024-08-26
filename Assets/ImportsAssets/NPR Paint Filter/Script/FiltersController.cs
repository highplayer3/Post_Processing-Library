using UnityEngine;

namespace NprPaintFilter
{
	[RequireComponent(typeof(Camera))]
	public class FiltersController : MonoBehaviour
	{
		public enum EFilter { None, BluePrint, CmykHalftone, Halftone, OilPaint, PencilSketch, PencilDot, AbstractPainting, WaterColor, Lego, Knitwear, TrianglesMosaic }
		public EFilter m_EnableFilter = EFilter.None;
		EFilter m_PrevEnableFilter = EFilter.None;
		BluePrint m_CompBluePrint;
		CmykHalftone m_CompCmykHalftone;
		OilPaint m_CompOilPaint;
		PencilSketch m_CompPencilSketch;
		PencilDot m_CompPencilDot;
		AbstractPainting m_CompAbstractPainting;
		WaterColor m_CompWaterColor;
		////////////////////////////////////////////////////////////////////////////////////////////////////
		[System.Serializable] public class TrianglesMosaic
		{
			public Material m_Mat;
			[Range(10, 60)] public float m_TileNumX = 40f;
			[Range(10, 60)] public float m_TileNumY = 20f;

			public void Apply()
			{
				m_Mat.SetVector("_TileNum", new Vector4(m_TileNumX, m_TileNumY, 0, 0));
			}
		}
		////////////////////////////////////////////////////////////////////////////////////////////////////
		[System.Serializable] public class Knitwear
		{
			public Material m_Mat;
			[Range(-2f, 2f)] public float m_Shear = 1f;
			[Range(1f, 200f)] public float m_Division = 60f;
			[Range(0.2f, 5f)] public float m_Aspect = 1f;
			public Texture2D m_Tex;

			public void Apply()
			{
				m_Mat.SetFloat("_KnitwearShear", m_Shear);
				m_Mat.SetFloat("_KnitwearDivision", m_Division);
				m_Mat.SetFloat("_KnitwearAspect", m_Aspect);
				m_Mat.SetTexture("_KnitwearTex", m_Tex);
			}
		}
		////////////////////////////////////////////////////////////////////////////////////////////////////
		[System.Serializable] public class Lego
		{
			public Material m_Mat;
			[Range(0.02f, 0.1f)] public float m_Size = 0.07f;

			public void Apply()
			{
				m_Mat.SetFloat("_Size", m_Size);
			}
		}
		////////////////////////////////////////////////////////////////////////////////////////////////////
		[System.Serializable] public class Halftone
		{
			public Material m_Mat;
			[Range(1f, 16f)] public float m_BlockSize = 8f;
			public float m_Scale = 256f;
			[Range(0f, 1f)] public float m_Fade = 0f;
			float[] m_BayerMatrix = new float[256];

			public void GenerateBayerDitherMatrix(int n)
			{
				int log2N = Mathf.RoundToInt(Mathf.Log(n, 2));
				int[,] temp = new int[n, n];
				temp[0, 0] = 0;
				temp[0, 1] = 3;
				temp[1, 0] = 2;
				temp[1, 1] = 1;
				int currentSize = 2;
				for (int i = 1; i < log2N; i++)
				{
					for (int row = 0; row < currentSize; row++) {
						for (int col = 0; col < currentSize; col++) {
							temp[row, col + currentSize] = temp[row, col] * 4 + 3;
						}
					}
					for (int row = 0; row < currentSize; row++) {
						for (int col = 0; col < currentSize; col++) {
							temp[row + currentSize, col] = temp[row, col] * 4 + 2;
						}
					}
					for (int row = 0; row < currentSize; row++) {
						for (int col = 0; col < currentSize; col++) {
							temp[row + currentSize, col + currentSize] = temp[row, col] * 4 + 1;
						}
					}
					for (int row = 0; row < currentSize; row++) {
						for (int col = 0; col < currentSize; col++) {
							temp[row, col] = temp[row, col] * 4;
						}
					}
					currentSize *= 2;
				}
				for (int i = 0; i < n * n; i++) {
					m_BayerMatrix[i] = (1f + temp[i / n, i % n]) / (1 + n * n);
				}
			}
			public void Apply()
			{
				m_Mat.SetFloatArray("_BayerMatrix", m_BayerMatrix);
				m_Mat.SetFloat("_Fade", m_Fade);
				m_Mat.SetFloat("_BlockSize", m_BlockSize);
				m_Mat.SetFloat("_Scale", m_Scale);
			}
		}
		////////////////////////////////////////////////////////////////////////////////////////////////////
		[Header("Lego")] public Lego m_Lego;
		[Header("Knitwear")] public Knitwear m_Knitwear;
		[Header("TrianglesMosaic")] public TrianglesMosaic m_TrianglesMosaic;
		[Header("Halftone")] public Halftone m_Halftone;

		void Start ()
		{
			m_Halftone.GenerateBayerDitherMatrix(16);

			m_CompBluePrint = GetComponent<BluePrint> ();
			if (m_CompBluePrint == null)
				m_CompBluePrint = gameObject.AddComponent<BluePrint> ();
			
			m_CompCmykHalftone = GetComponent<CmykHalftone> ();
			if (m_CompCmykHalftone == null)
				m_CompCmykHalftone = gameObject.AddComponent<CmykHalftone> ();
			
			m_CompOilPaint = GetComponent<OilPaint> ();
			if (m_CompOilPaint == null)
				m_CompOilPaint = gameObject.AddComponent<OilPaint> ();
			
			m_CompPencilSketch = GetComponent<PencilSketch> ();
			if (m_CompPencilSketch == null)
				m_CompPencilSketch = gameObject.AddComponent<PencilSketch> ();
				
			m_CompPencilDot = GetComponent<PencilDot> ();
			if (m_CompPencilDot == null)
				m_CompPencilDot = gameObject.AddComponent<PencilDot> ();
				
			m_CompAbstractPainting = GetComponent<AbstractPainting> ();
			if (m_CompAbstractPainting == null)
				m_CompAbstractPainting = gameObject.AddComponent<AbstractPainting> ();
			
			m_CompWaterColor = GetComponent<WaterColor> ();
			if (m_CompWaterColor == null)
				m_CompWaterColor = gameObject.AddComponent<WaterColor> ();
			
			ApplyFilter();
		}
		void Update()
		{
			if (m_PrevEnableFilter != m_EnableFilter)
			{
				m_PrevEnableFilter = m_EnableFilter;
				ApplyFilter();
			}
			if (EFilter.TrianglesMosaic == m_EnableFilter)
				m_TrianglesMosaic.Apply();
			else if (EFilter.Knitwear == m_EnableFilter)
				m_Knitwear.Apply();
			else if (EFilter.Lego == m_EnableFilter)
				m_Lego.Apply();
			else if (EFilter.Halftone == m_EnableFilter)
				m_Halftone.Apply();
		}
		void ApplyFilter()
		{
			m_CompBluePrint.enabled  = false;
			m_CompCmykHalftone.enabled  = false;
			m_CompOilPaint.enabled  = false;
			m_CompPencilSketch.enabled  = false;
			m_CompPencilDot.enabled = false;
			m_CompAbstractPainting.enabled = false;
			m_CompWaterColor.enabled = false;

			if (EFilter.BluePrint == m_EnableFilter)
				m_CompBluePrint.enabled = true;
			if (EFilter.CmykHalftone == m_EnableFilter)
				m_CompCmykHalftone.enabled = true;
			if (EFilter.OilPaint == m_EnableFilter)
				m_CompOilPaint.enabled = true;
			if (EFilter.PencilSketch == m_EnableFilter)
				m_CompPencilSketch.enabled = true;
			if (EFilter.PencilDot == m_EnableFilter)
				m_CompPencilDot.enabled = true;
			if (EFilter.AbstractPainting == m_EnableFilter)
				m_CompAbstractPainting.enabled = true;
			if (EFilter.WaterColor == m_EnableFilter)
				m_CompWaterColor.enabled = true;
		}
		void OnRenderImage(RenderTexture src, RenderTexture dst)
		{
			if (EFilter.Lego == m_EnableFilter)
				Graphics.Blit(src, dst, m_Lego.m_Mat);
			else if (EFilter.Knitwear == m_EnableFilter)
				Graphics.Blit(src, dst, m_Knitwear.m_Mat);
			else if (EFilter.TrianglesMosaic == m_EnableFilter)
				Graphics.Blit(src, dst, m_TrianglesMosaic.m_Mat);
			else if (EFilter.Halftone == m_EnableFilter)
				Graphics.Blit(src, dst, m_Halftone.m_Mat);
			else
				Graphics.Blit(src, dst);
		}
	}
}