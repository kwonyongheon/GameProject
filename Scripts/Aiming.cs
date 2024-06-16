using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerAiming : MonoBehaviour
{
    public Transform aimPosition; // ������ �� ���⸦ �̵���ų ��ġ
    public float aimSpeed = 5f; // ���� �ӵ�
    public Camera playerCamera; // �� ī�޶�
    public float aimFOV = 30f; // �Ϲ� ���� ���� �� �þ߰�
    public float sniperAimFOV = 15f; // �������� ���� ���� �� �þ߰�
    private float defaultFOV; // �⺻ �þ߰�
    private Vector3 defaultWeaponPosition; // �⺻ ���� ��ġ
    public bool isSniper = false; // �������� ���� ����

    private bool isAiming = false; // �÷��̾ ���� ������ ����

    public Image crosshair; // ������ �̹���

    public Weapon currentWeapon; // ���� ������ ����

    private void Start()
    {
        // �⺻ �þ߰��� ���� ��ġ ����
        if (playerCamera != null)
        {
            defaultFOV = playerCamera.fieldOfView;
        }

        if (aimPosition != null)
        {
            defaultWeaponPosition = transform.localPosition;
        }

        // ������ ��Ȱ��ȭ
        if (crosshair != null)
        {
            crosshair.enabled = false;
        }
    }

    private void Update()
    {
        if (currentWeapon != null) // ���Ⱑ ���� ���� ���� ����
        {
            Aim();
        }
    }

    private void Aim()
    {
        if (Input.GetMouseButtonDown(1)) // ������ ���콺 ��ư�� ������ ��
        {
            isAiming = true;
            if (crosshair != null)
            {
                crosshair.enabled = true; // ������ Ȱ��ȭ
            }
        }

        if (Input.GetMouseButtonUp(1)) // ������ ���콺 ��ư�� ���� ��
        {
            isAiming = false;
            if (crosshair != null)
            {
                crosshair.enabled = false; // ������ ��Ȱ��ȭ
            }
        }

        if (isAiming)
        {
            // ���⸦ ���� ��ġ�� �ε巴�� �̵�
            transform.localPosition = Vector3.Lerp(transform.localPosition, aimPosition.localPosition, Time.deltaTime * aimSpeed);

            // ī�޶� �þ߰��� ���ؿ����� ����
            if (playerCamera != null)
            {
                playerCamera.fieldOfView = Mathf.Lerp(playerCamera.fieldOfView, isSniper ? sniperAimFOV : aimFOV, Time.deltaTime * aimSpeed);
            }
        }
        else
        {
            // ���⸦ �⺻ ��ġ�� �ε巴�� �̵�
            transform.localPosition = Vector3.Lerp(transform.localPosition, defaultWeaponPosition, Time.deltaTime * aimSpeed);

            // ī�޶� �þ߰��� �⺻������ ����
            if (playerCamera != null)
            {
                playerCamera.fieldOfView = Mathf.Lerp(playerCamera.fieldOfView, defaultFOV, Time.deltaTime * aimSpeed);
            }
        }
    }
}
