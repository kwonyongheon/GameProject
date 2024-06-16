using System.Collections;
using UnityEngine;

public class BossAttack : MonoBehaviour
{
    public enum ProjectileType { Fireball, Iceball, Slowball } // 발사체 유형
    public ProjectileType projectileType; // 발사체 유형 변수

    public int fireballInitialDamage = 20;
    public int fireballTickDamage = 5;
    public float fireballDuration = 3f;

    public int iceballDamage = 15;
    public float iceballFreezeDuration = 0.5f;

    public int slowballDamage = 20;
    public float slowballSlowDuration = 1f; // 슬로우 지속 시간
    public float slowballSlowMultiplier = 0.7f; // 슬로우 속도 감소 비율

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("충돌 감지: " + other.name);
        if (other.CompareTag("Player"))
        {
            Debug.Log("발사체가 플레이어를 맞췄습니다.");
            Player player = other.GetComponent<Player>();
            if (player != null)
            {
                switch (projectileType)
                {
                    case ProjectileType.Fireball:
                        player.TakeDamage(fireballInitialDamage);
                        StartCoroutine(ApplyTickDamage(player, fireballTickDamage, fireballDuration));
                        break;
                    case ProjectileType.Iceball:
                        player.TakeDamage(iceballDamage);
                        StartCoroutine(FreezePlayer(player, iceballFreezeDuration));
                        break;
                    case ProjectileType.Slowball:
                        player.TakeDamage(slowballDamage);
                        StartCoroutine(SlowPlayer(player, slowballSlowMultiplier, slowballSlowDuration));
                        break;
                }
                StartCoroutine(DestroyAfterDelay(3f)); // 3초 후에 발사체 파괴
            }
        }
    }

    private IEnumerator ApplyTickDamage(Player player, int tickDamage, float duration)
    {
        Debug.Log("플레이어에게 틱 데미지 적용 중.");
        float tickInterval = 1f;
        float elapsedTime = 0f;
        while (elapsedTime < duration)
        {
            yield return new WaitForSeconds(tickInterval);
            player.TakeDamage(tickDamage);
            elapsedTime += tickInterval;
            Debug.Log("틱 데미지 적용됨. 경과 시간: " + elapsedTime);
        }
        Debug.Log("틱 데미지 적용 완료.");
    }

    private IEnumerator FreezePlayer(Player player, float duration)
    {
        Debug.Log("플레이어 얼리기.");
        player.canMove = false;
        yield return new WaitForSeconds(duration);
        player.canMove = true;
        Debug.Log("플레이어 언프리즈.");
    }

    private IEnumerator SlowPlayer(Player player, float slowMultiplier, float duration)
    {
        Debug.Log("플레이어 슬로우.");
        float originalSpeed = player.moveSpeed;
        player.moveSpeed *= slowMultiplier;
        Debug.Log($"플레이어 속도 감소: {player.moveSpeed}");
        yield return new WaitForSeconds(duration);
        player.moveSpeed = originalSpeed;
        Debug.Log($"플레이어 속도 복구: {player.moveSpeed}");
    }

    private IEnumerator DestroyAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);
        Destroy(gameObject);
    }
}
